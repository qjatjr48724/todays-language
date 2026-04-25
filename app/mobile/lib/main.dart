import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_session_watcher.dart';
import 'firebase_options.dart';
import 'screens/launch_screen.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      title: "Today's Language",
      theme: AppTheme.light(),
      navigatorKey: navKey,
      builder: (context, child) {
        return AuthSessionWatcher(
          navigatorKey: navKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LaunchScreen(),
    );
  }
}
