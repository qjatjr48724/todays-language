import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/analytics/analytics_action_log.dart';

/// 학습 화면 Callable 호출 전체 타임아웃(오프라인 시 무한 로딩 방지).
const Duration kCallableLoadTimeout = Duration(seconds: 30);

/// Auth 토큰 조회·갱신만의 상한(오프라인에서 true 갱신이 길게 걸리는 것 방지).
const Duration kAuthTokenTimeout = Duration(seconds: 15);

Future<void> _ensureIdToken(
  User user, {
  required bool forceRefresh,
}) async {
  await user.getIdToken(forceRefresh).timeout(kAuthTokenTimeout);
}

Future<Map<String, dynamic>> _callCallable(
  HttpsCallable callable,
  Map<String, dynamic> data,
) async {
  final result = await callable.call<Map<String, dynamic>>(data);
  return Map<String, dynamic>.from(result.data as Map);
}

/// Callable 호출. 기본은 캐시 토큰([forceRefreshToken] false), 필요 시에만 갱신합니다.
///
/// [forceRefreshToken] true(다시 불러오기 등): 먼저 토큰 갱신 후 호출.
/// Functions [unauthenticated] 시 1회 토큰 갱신 후 재호출합니다.
Future<Map<String, dynamic>> invokeCallableMap(
  HttpsCallable callable,
  Map<String, dynamic> data, {
  Duration timeout = kCallableLoadTimeout,
  bool forceRefreshToken = false,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('not_signed_in');
  }

  Future<Map<String, dynamic>> run() async {
    await _ensureIdToken(user, forceRefresh: forceRefreshToken);

    try {
      return await _callCallable(callable, data);
    } on FirebaseFunctionsException catch (e) {
      if (e.code != 'unauthenticated' || forceRefreshToken) {
        rethrow;
      }
      await _ensureIdToken(user, forceRefresh: true);
      return await _callCallable(callable, data);
    }
  }

  try {
    return await run().timeout(timeout);
  } catch (e, st) {
    await logCallableFailure(e, st);
    rethrow;
  }
}

/// Callable 로드 실패 메시지용 상세 문자열(타임아웃·Functions 코드).
String formatCallableLoadError(
  Object e, {
  Duration timeout = kCallableLoadTimeout,
}) {
  if (e is TimeoutException) {
    return 'timeout (${timeout.inSeconds}s)';
  }
  if (e is FirebaseFunctionsException) {
    final msg = e.message?.trim();
    if (msg != null && msg.isNotEmpty) {
      return '${e.code}: $msg';
    }
    return e.code;
  }
  return e.toString();
}
