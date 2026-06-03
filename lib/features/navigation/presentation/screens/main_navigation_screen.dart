import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:livestock/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:livestock/features/dashboard/presentation/screens/collection_agent_dashboard.dart';
import 'package:livestock/features/farmer_management/presentation/screens/farmer_list_screen.dart';
import 'package:livestock/features/milk_collection/presentation/screens/milk_collection_main_screen.dart';
import 'package:livestock/features/navigation/presentation/providers/navigation_providers.dart';
import 'package:livestock/features/navigation/presentation/screens/more_menu_screen.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Main navigation screen with persistent bottom navigation bar
/// 
/// This screen manages the five primary activities of the app:
/// - Home/Dashboard
/// - Farmers
/// - Analytics & Report
/// - Milk Collection
/// - More Menu
/// 
/// Uses IndexedStack to preserve state of each screen when switching tabs.
class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  /// Initial tab index to display (for deep linking)
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the navigation index if this is the first build
    if (initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationIndexProvider.notifier).setIndex(initialIndex);
      });
    }

    // Watch the current navigation index
    final currentIndex = ref.watch(navigationIndexProvider);

    // Ensure index is within bounds (0-4 for 5 tabs)
    final safeIndex = currentIndex.clamp(0, 4);
    if (safeIndex != currentIndex) {
      // Reset to safe index if out of bounds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationIndexProvider.notifier).setIndex(safeIndex);
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: const [
          CollectionAgentDashboard(),
          FarmerListScreen(),
          MilkCollectionMainScreen(),
          AnalyticsDashboardScreen(),
          MoreMenuScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedHome09),
            label: AppLocalizations.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserList),
            label: AppLocalizations.of(context).farmers,
          ),
          BottomNavigationBarItem(
            icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedRainDrop),
            label: AppLocalizations.of(context).collection,
          ),
                  BottomNavigationBarItem(
            icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAnalysisTextLink),
            label: AppLocalizations.of(context).analyticsReport,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: AppLocalizations.of(context).more,
          ),
        ],
        onTap: (index) {
          // Update the navigation index when a tab is tapped
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
