import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_gate.dart';
import '../l10n/app_localizations.dart';
import 'notification_permission_screen.dart';

enum _BlockReason {
  internet,
  login,
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  static const _prefsKeyHasLaunched = 'hasLaunched';
  static const _prefsKeyNotificationPermissionAsked =
      NotificationPermissionScreen.prefsKeyAsked;

  bool _loading = true;
  bool _firstLaunch = false;
  bool _navigating = false;

  _BlockReason? _blockReason;

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
      _blockReason = null;
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
      _blockReason = null;
    });

    final hasInternet = await _hasInternetConnection();
    if (!mounted) return;
    if (!hasInternet) {
      setState(() {
        _navigating = false;
        _blockReason = _BlockReason.internet;
      });
      return;
    }

    // 로그인 여부 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (!mounted) return;
      await _maybeAskNotificationPermission();
      if (!mounted) return;
      // 로그인 상태라도 AuthGate를 거쳐서 들어가야,
      // 이후 세션 변경(로그아웃/토큰 무효화)에도 일관되게 화면 전환이 됩니다.
      Navigator.of(context).pushReplacement(_fadeRoute(const AuthGate()));
      return;
    }

    setState(() {
      _navigating = false;
      _blockReason = _BlockReason.login;
    });
  }

  Future<void> _markLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyHasLaunched, true);
  }

  Future<void> _maybeAskNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool(_prefsKeyNotificationPermissionAsked) ?? false;
    if (asked) return;

    if (!mounted) return;
    final nav = Navigator.of(context);
    await nav.push(
      MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()),
    );

    // 사용자가 허용/거부 어떤 선택을 하든 "한 번은 물어봤다"로 기록합니다.
    await prefs.setBool(_prefsKeyNotificationPermissionAsked, true);
  }

  Future<void> _onTap() async {
    if (_navigating || _loading) return;

    // 첫 실행: 터치 후 로그인/회원가입 화면으로
    if (_firstLaunch) {
      setState(() => _navigating = true);
      await _markLaunched();
      if (!mounted) return;
      await _maybeAskNotificationPermission();
      if (!mounted) return;
      // 이후 로그인 성공 시 자동으로 홈으로 전환되도록 AuthGate를 루트로 둡니다.
      Navigator.of(context).pushReplacement(_fadeRoute(const AuthGate()));
      return;
    }

    // 재실행인데 로그인 풀림/오프라인 등으로 자동 전환이 막힌 경우
    if (_blockReason != null) {
      if (_blockReason == _BlockReason.internet) {
        await _autoNavigate();
        return;
      }
      // 로그인 안내 문구 상태면 로그인 화면으로 이동
      setState(() => _navigating = true);
      await _maybeAskNotificationPermission();
      if (!mounted) return;
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
    final l10n = AppLocalizations.of(context)!;

    final showPrompt = !_loading &&
        (_firstLaunch ||
            _blockReason != null ||
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
                l10n.launch_title,
                style: t.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.launch_subtitle,
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
                                    ? l10n.launch_prompt_tap
                                    : (_blockReason == _BlockReason.internet
                                        ? l10n.launch_internet_required
                                        : _blockReason == _BlockReason.login
                                            ? l10n.launch_login_required
                                            : l10n.launch_prompt_tap),
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
