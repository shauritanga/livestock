import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for onboarding state
class OnboardingLocalDataSource {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  
  final SharedPreferences sharedPreferences;
  
  OnboardingLocalDataSource(this.sharedPreferences);
  
  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    return sharedPreferences.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  /// Mark onboarding as seen
  Future<void> setOnboardingSeen() async {
    await sharedPreferences.setBool(_hasSeenOnboardingKey, true);
  }
  
  /// Reset onboarding state (for testing)
  Future<void> resetOnboarding() async {
    await sharedPreferences.remove(_hasSeenOnboardingKey);
  }
}
