import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth_session_watcher.dart';
import 'firebase_options.dart';
import 'screens/launch_screen.dart';
import 'ui/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // navigatorKey는 build마다 새로 생성되면 네비게이터 트리가 리셋/꼬일 수 있어
  // State에 고정합니다.
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  Locale _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) return const Locale('en');

    // 1) exact match (language+country)
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          (supported.countryCode ?? '') == (locale.countryCode ?? '')) {
        return supported;
      }
    }

    // 2) language-only match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }

    // 3) fallback to English (project rule)
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Today's Language",
      theme: AppTheme.light(),
      navigatorKey: _navKey,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Android는 locale "리스트"를 전달합니다.
      // 규칙: (1) 첫 번째(기본) locale만 기준으로 판단한다.
      //      (2) 미지원 언어이면, 리스트의 다음 언어로 넘어가지 않고 무조건 en으로 fallback 한다.
      localeListResolutionCallback: (locales, supportedLocales) {
        final primary = (locales == null || locales.isEmpty) ? null : locales.first;
        return _resolveLocale(primary, supportedLocales);
      },
      localeResolutionCallback: (locale, supportedLocales) {
        return _resolveLocale(locale, supportedLocales);
      },
      builder: (context, child) {
        return AuthSessionWatcher(
          navigatorKey: _navKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LaunchScreen(),
    );
  }
}
