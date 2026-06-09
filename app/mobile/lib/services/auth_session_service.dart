import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 단일 기기 활성 로그인 세션을 Firestore + 로컬 저장소로 관리합니다.
///
/// - 로그인 성공 시 [claimSession]으로 `users/{uid}.activeSessionId`를 갱신합니다.
/// - 다른 기기에서 동일 계정 로그인 시 이전 기기는 세션 불일치로 로그아웃됩니다.
class AuthSessionService {
  AuthSessionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const fieldSessionId = 'activeSessionId';
  static const fieldSessionUpdatedAtMs = 'activeSessionUpdatedAtMs';
  static const prefsKeySessionId = 'active_auth_session_id';
  static const prefsKeySessionUid = 'active_auth_session_uid';

  static Future<void>? _pendingClaim;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;


  /// 로그인 성공 직후 호출 — 새 세션을 선점하고 이전 기기를 무효화합니다.
  Future<void> claimSession(User user) async {
    final claim = _claimSessionImpl(user);
    _pendingClaim = claim;
    try {
      await claim;
    } finally {
      if (identical(_pendingClaim, claim)) {
        _pendingClaim = null;
      }
    }
  }


  Future<void> _claimSessionImpl(User user) async {
    final sessionId = generateSessionId();
    await _persistLocal(user.uid, sessionId);
    await _firestore.collection('users').doc(user.uid).set({
      fieldSessionId: sessionId,
      fieldSessionUpdatedAtMs: DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }


  /// 앱 cold start 또는 세션 복구 시 로컬·원격 세션 일치 여부를 검증합니다.
  Future<bool> verifySessionOrSignOut(User user) async {
    if (_pendingClaim != null) {
      await _pendingClaim;
    }

    final prefs = await SharedPreferences.getInstance();
    var localId = prefs.getString(prefsKeySessionId);
    var localUid = prefs.getString(prefsKeySessionUid);

    if (!hasValidLocalSession(localUid: localUid, localId: localId, uid: user.uid)) {
      // 로그인 직후 claim이 아직 반영되지 않은 경우 한 번 재시도
      await Future<void>.delayed(const Duration(milliseconds: 400));
      localId = prefs.getString(prefsKeySessionId);
      localUid = prefs.getString(prefsKeySessionUid);
      if (!hasValidLocalSession(localUid: localUid, localId: localId, uid: user.uid)) {
        await _signOutAndClearLocal();
        return false;
      }
    }

    final snap = await _firestore.collection('users').doc(user.uid).get();
    final remoteId = snap.data()?[fieldSessionId] as String?;

    if (remoteId == null || remoteId.isEmpty) {
      await claimSession(user);
      return true;
    }

    if (isSessionMismatch(localId: localId, remoteId: remoteId)) {
      await _signOutAndClearLocal();
      return false;
    }

    return true;
  }


  /// Firestore 프로필의 activeSessionId 변화를 감시합니다. 불일치 시 [onInvalid] 호출.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> watchActiveSession({
    required User user,
    required void Function() onInvalid,
  }) {
    return _firestore.collection('users').doc(user.uid).snapshots().listen(
      (snap) {
        if (_pendingClaim != null) return;

        final remoteId = snap.data()?[fieldSessionId] as String?;
        if (remoteId == null || remoteId.isEmpty) return;

        SharedPreferences.getInstance().then((prefs) {
          final localId = prefs.getString(prefsKeySessionId);
          final localUid = prefs.getString(prefsKeySessionUid);
          if (!hasValidLocalSession(localUid: localUid, localId: localId, uid: user.uid)) {
            return;
          }
          if (isSessionMismatch(localId: localId, remoteId: remoteId)) {
            onInvalid();
          }
        });
      },
      onError: (_) {},
    );
  }


  Future<void> clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKeySessionId);
    await prefs.remove(prefsKeySessionUid);
  }


  Future<void> _signOutAndClearLocal() async {
    await clearLocalSession();
    await _auth.signOut();
  }


  Future<void> _persistLocal(String uid, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKeySessionId, sessionId);
    await prefs.setString(prefsKeySessionUid, uid);
  }
}


/// 로컬·원격 세션 ID가 일치하지 않으면 true (다른 기기 로그인).
bool isSessionMismatch({required String? localId, required String? remoteId}) {
  if (remoteId == null || remoteId.isEmpty) return false;
  if (localId == null || localId.isEmpty) return true;
  return localId != remoteId;
}


/// 로컬에 저장된 세션이 현재 uid와 연결되어 있는지 확인합니다.
bool hasValidLocalSession({
  required String? localUid,
  required String? localId,
  required String uid,
}) {
  if (localUid != uid) return false;
  if (localId == null || localId.isEmpty) return false;
  return true;
}


/// 세션 ID 생성 — secure random + 타임스탬프
String generateSessionId() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  return '${DateTime.now().microsecondsSinceEpoch}-${base64Url.encode(bytes)}';
}
