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
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
