import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics/analytics_action_log.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/analytics/app_analytics_service.dart';
import '../services/analytics/tracked_scaffold.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'my_info_screen.dart';
import 'progress_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 1;
  final GlobalKey<ProgressScreenState> _progressKey =
      GlobalKey<ProgressScreenState>();
  DateTime? _tabEnteredAt;

  static const _tabNames = <String>[
    AnalyticsScreens.myInfo,
    AnalyticsScreens.home,
    AnalyticsScreens.community,
    AnalyticsScreens.progress,
  ];

  @override
  void initState() {
    super.initState();
    _tabEnteredAt = DateTime.now();
    AppAnalyticsService.instance.logScreenView(_tabNames[_index]);
  }

  Future<void> _onTabSelected(int i) async {
    if (i == _index) return;
    final prev = _tabNames[_index];
    final entered = _tabEnteredAt;
    if (entered != null) {
      await AppAnalyticsService.instance.logScreenDwell(
        prev,
        DateTime.now().difference(entered),
      );
    }
    setState(() => _index = i);
    _tabEnteredAt = DateTime.now();
    await logTabSelect(_tabNames[i]);
    await AppAnalyticsService.instance.logScreenView(_tabNames[i]);
    if (i == 3) {
      _progressKey.currentState?.refreshFromTab();
    }
  }

  @override
  void dispose() {
    final entered = _tabEnteredAt;
    if (entered != null) {
      AppAnalyticsService.instance.logScreenDwell(
        _tabNames[_index],
        DateTime.now().difference(entered),
      );
    }
    super.dispose();
  }

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
      const CommunityScreen(),
      ProgressScreen(key: _progressKey),
    ];

    return trackedScaffold(
      screenName: AnalyticsScreens.mainNav,
      scaffold: Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      // Material 3 테마(useMaterial3: true)에서는 NavigationBar가 더 안정적으로 표시됩니다.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: l10n.my_info_screen_title,
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: l10n.home_home_tab_title,
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: l10n.community_tab_title,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: l10n.progress_appbar_title,
          ),
        ],
      ),
    ),
    );
  }
}
