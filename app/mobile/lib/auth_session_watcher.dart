import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_gate.dart';

/// 앱 전역에서 로그인 세션 변화를 감시해, 세션이 풀리면 AuthGate로 복귀시킵니다.
///
/// - 첫 실행(설치 직후)에는 스플래시 UX(터치해서 시작)를 유지해야 하므로,
///   `hasLaunched == true`인 경우에만 강제 리다이렉트를 수행합니다.
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

  StreamSubscription<User?>? _sub;
  bool _hasLaunched = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasLaunched = prefs.getBool(_prefsKeyHasLaunched) ?? false;
    _ready = true;

    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_ready || !_hasLaunched) return;
      if (user != null) return;

      final nav = widget.navigatorKey.currentState;
      if (nav == null) return;

      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

