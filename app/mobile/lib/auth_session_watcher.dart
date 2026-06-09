import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_gate.dart';
import 'l10n/app_localizations.dart';
import 'services/auth_session_service.dart';

/// 앱 전역에서 로그인 세션 변화를 감시해, 세션이 풀리면 AuthGate로 복귀시킵니다.
///
/// - 첫 실행(설치 직후)에는 스플래시 UX(터치해서 시작)를 유지해야 하므로,
///   `hasLaunched == true`인 경우에만 강제 리다이렉트를 수행합니다.
/// - 동일 계정의 다른 기기 로그인 시 [AuthSessionService]로 이 기기를 로그아웃합니다.
class AuthSessionWatcher extends StatefulWidget {
  const AuthSessionWatcher({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<AuthSessionWatcher> createState() => _AuthSessionWatcherState();
}

class _AuthSessionWatcherState extends State<AuthSessionWatcher> {
  static const _prefsKeyHasLaunched = 'hasLaunched';

  final AuthSessionService _sessionService = AuthSessionService();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  String? _watchedUid;
  bool _hasLaunched = false;
  bool _ready = false;
  bool _handlingInvalidSession = false;

  @override
  void initState() {
    super.initState();
    _init();
  }


  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasLaunched = prefs.getBool(_prefsKeyHasLaunched) ?? false;
    _ready = true;

    final current = FirebaseAuth.instance.currentUser;
    if (_hasLaunched && current != null) {
      await _startSessionWatch(current);
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!_ready || !_hasLaunched) return;

      if (user == null) {
        await _stopSessionWatch();
        await _sessionService.clearLocalSession();
        _redirectToAuthGate();
        return;
      }

      if (_watchedUid != user.uid) {
        await _startSessionWatch(user);
      }
    });
  }


  Future<void> _startSessionWatch(User user) async {
    await _stopSessionWatch();
    _watchedUid = user.uid;

    final valid = await _sessionService.verifySessionOrSignOut(user);
    if (!valid) {
      _watchedUid = null;
      _redirectToAuthGate(showDuplicateLoginMessage: true);
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) return;

    _profileSub = _sessionService.watchActiveSession(
      user: user,
      onInvalid: _handleSessionInvalidated,
    );
  }


  Future<void> _handleSessionInvalidated() async {
    if (_handlingInvalidSession) return;
    _handlingInvalidSession = true;
    try {
      await _stopSessionWatch();
      await _sessionService.clearLocalSession();
      await FirebaseAuth.instance.signOut();
      _redirectToAuthGate(showDuplicateLoginMessage: true);
    } finally {
      _handlingInvalidSession = false;
    }
  }


  Future<void> _stopSessionWatch() async {
    await _profileSub?.cancel();
    _profileSub = null;
    _watchedUid = null;
  }


  void _redirectToAuthGate({bool showDuplicateLoginMessage = false}) {
    final nav = widget.navigatorKey.currentState;
    if (nav == null) return;

    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );

    if (!showDuplicateLoginMessage) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = widget.navigatorKey.currentContext;
      if (ctx == null) return;
      final l10n = AppLocalizations.of(ctx);
      if (l10n == null) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(l10n.auth_session_duplicate_login)),
      );
    });
  }


  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
