import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/onboarding_local_datasource.dart';
import '../../domain/entities/onboarding_page.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for OnboardingLocalDataSource
final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalDataSource(sharedPreferences);
});

/// Provider for checking if user has seen onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final dataSource = ref.watch(onboardingLocalDataSourceProvider);
  return await dataSource.hasSeenOnboarding();
});

/// Provider for onboarding pages
final onboardingPagesProvider = Provider<List<OnboardingPage>>((ref) {
  return [
    const OnboardingPage(
      title: 'Welcome to Agripoa',
      description: 'Transform your dairy farming with digital milk collection, cattle tracking, and financial services all in one platform.',
      imagePath: 'assets/images/onboarding_1.png',
      iconData: 'agriculture',
    ),
    const OnboardingPage(
      title: 'Track Your Cattle',
      description: 'Register your cattle with biometric identification using muzzle patterns. Track production, health status, and breeding information.',
      imagePath: 'assets/images/onboarding_2.png',
      iconData: 'pets',
    ),
    const OnboardingPage(
      title: 'Record Milk Deliveries',
      description: 'Quickly record daily milk deliveries with quantity and quality measurements. Get instant payment calculations.',
      imagePath: 'assets/images/onboarding_3.png',
      iconData: 'water_drop',
    ),
    const OnboardingPage(
      title: 'Access Financial Services',
      description: 'Apply for input loans and livestock insurance. Automatic repayment through milk payments makes it easy and convenient.',
      imagePath: 'assets/images/onboarding_4.png',
      iconData: 'account_balance',
    ),
    const OnboardingPage(
      title: 'Work Offline',
      description: 'Record data even without internet connection. Everything syncs automatically when you\'re back online.',
      imagePath: 'assets/images/onboarding_5.png',
      iconData: 'cloud_off',
    ),
  ];
});

/// Notifier for current onboarding page index
class OnboardingPageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void setPage(int page) => state = page;
}

final onboardingPageIndexProvider = NotifierProvider<OnboardingPageIndexNotifier, int>(
  OnboardingPageIndexNotifier.new,
);
