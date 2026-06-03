import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for managing the currently selected bottom navigation tab index
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Update the selected tab index
  void setIndex(int index) {
    if (index >= 0 && index <= 4) {
      state = index;
    }
  }
}

/// Provider for managing the currently selected bottom navigation tab index
/// 
/// Values:
/// - 0: Home/Dashboard
/// - 1: Farmers
/// - 2: Cattle Tracking
/// - 3: Milk Collection
/// - 4: More Menu
final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);
