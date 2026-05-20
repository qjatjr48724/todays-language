import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'home_screen.dart';
import 'my_info_screen.dart';
import 'progress_screen.dart';
import '../l10n/app_localizations.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 1;
  final GlobalKey<ProgressScreenState> _progressKey =
      GlobalKey<ProgressScreenState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) {
      final locale = Localizations.localeOf(context);
      debugPrint(
        '[MainNavScreen] locale=$locale labels='
        '${l10n.my_info_screen_title}, ${l10n.home_home_tab_title}, ${l10n.progress_appbar_title}',
      );
    }
    final pages = [
      const MyInfoScreen(embedded: true),
      const HomeScreen(showMyInfoButton: false),
      ProgressScreen(key: _progressKey),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 2) {
            _progressKey.currentState?.refreshFromTab();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: l10n.my_info_screen_title,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: l10n.home_home_tab_title,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: l10n.progress_appbar_title,
          ),
        ],
      ),
    );
  }
}
