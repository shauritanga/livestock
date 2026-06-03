import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

/// Notifier to manage locale changes
class LocaleNotifier extends Notifier<Locale> {
  static const String _localeKey = 'app_locale';

  @override
  Locale build() {
    // Load saved locale synchronously
    final prefs = ref.read(sharedPreferencesProvider);
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null && ['en', 'sw'].contains(languageCode)) {
      return Locale(languageCode, '');
    }
    
    // Default to Swahili
    return const Locale('sw', '');
  }

  /// Change locale and persist to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
      // Continue with in-memory state
    }
  }

  /// Get current locale
  Locale get currentLocale => state;
}

/// Provider for LocaleNotifier
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Provider for locale display name
final localeDisplayNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'sw' ? 'Kiswahili' : 'English (US)';
});
