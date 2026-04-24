import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_gate.dart';
import 'main_nav_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  static const _prefsKeyHasLaunched = 'hasLaunched';

  bool _loading = true;
  bool _firstLaunch = false;
  bool _navigating = false;

  String? _blockingMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(_prefsKeyHasLaunched) ?? false;
    if (!mounted) return;

    setState(() {
      _firstLaunch = !hasLaunched;
      _loading = false;
      _blockingMessage = null;
    });

    // 재실행 시: 1초 로고 유지 후 자동 전환
    if (hasLaunched) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await _autoNavigate();
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      // 인터넷 연결 필수 정책: DNS lookup + 타임아웃으로 최소 확인
      final result = await InternetAddress.lookup('firebase.google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _autoNavigate() async {
    if (_navigating) return;
    setState(() {
      _navigating = true;
      _blockingMessage = null;
    });

    final hasInternet = await _hasInternetConnection();
    if (!mounted) return;
    if (!hasInternet) {
      setState(() {
        _navigating = false;
        _blockingMessage = '인터넷 연결이 필요합니다.\n네트워크 연결을 확인한 뒤 다시 시도해 주세요.';
      });
      return;
    }

    // 로그인 여부 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        _fadeRoute(const MainNavScreen()),
      );
      return;
    }

    setState(() {
      _navigating = false;
      _blockingMessage = '로그인이 필요합니다.\n시작하려면 터치해주세요.';
    });
  }

  Future<void> _markLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyHasLaunched, true);
  }

  Future<void> _onTap() async {
    if (_navigating || _loading) return;

    // 첫 실행: 터치 후 로그인/회원가입 화면으로
    if (_firstLaunch) {
      setState(() => _navigating = true);
      await _markLaunched();
      if (!mounted) return;
      // 이후 로그인 성공 시 자동으로 홈으로 전환되도록 AuthGate를 루트로 둡니다.
      Navigator.of(context).pushReplacement(_fadeRoute(const AuthGate()));
      return;
    }

    // 재실행인데 로그인 풀림/오프라인 등으로 자동 전환이 막힌 경우
    if (_blockingMessage != null) {
      if (_blockingMessage!.contains('인터넷')) {
        await _autoNavigate();
        return;
      }
      // 로그인 안내 문구 상태면 로그인 화면으로 이동
      setState(() => _navigating = true);
      Navigator.of(context).pushReplacement(_fadeRoute(const AuthGate()));
    }
  }

  PageRouteBuilder<void> _fadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final showPrompt = !_loading &&
        (_firstLaunch ||
            _blockingMessage != null ||
            (!_navigating && FirebaseAuth.instance.currentUser == null));

    return Scaffold(
      body: InkWell(
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            children: [
              const Spacer(),
              Text(
                '오늘의 언어',
                style: t.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                "Today's Language",
                style: t.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              // 하단 영역은 높이를 고정해, 상태 변화(로딩/문구 변경)에도 로고가 흔들리지 않게 합니다.
              SizedBox(
                height: 64,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: (_loading || _navigating)
                        ? const SizedBox(
                            key: ValueKey('spinner'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (showPrompt
                            ? Text(
                                key: const ValueKey('prompt'),
                                _firstLaunch
                                    ? '시작하려면 터치해주세요'
                                    : (_blockingMessage ?? '시작하려면 터치해주세요'),
                                textAlign: TextAlign.center,
                                style: t.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty'))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
