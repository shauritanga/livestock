import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

// Temporary locale notifier until the actual one is created
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en', '');

  void setLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Farmer Profile and Settings Screen
class FarmerProfileSettingsScreen extends ConsumerWidget {
  const FarmerProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profileSettings),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            _getUserInitials(user?.displayName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Farmer',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.phoneNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.phoneNumber!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Contact information section
          Text(
            AppLocalizations.of(context).contactInformation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(AppLocalizations.of(context).phoneNumber),
                  subtitle: Text(user?.phoneNumber ?? 'Not Set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to edit phone number
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(AppLocalizations.of(context).email),
                  subtitle: Text(user?.email ?? 'Not Set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to edit email
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // App settings section
          Text(
            AppLocalizations.of(context).appSettings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context).language),
                  subtitle: Text(_getLanguageName(currentLocale)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, ref, currentLocale),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(AppLocalizations.of(context).notifications),
                  subtitle: Text(AppLocalizations.of(context).manageNotificationSettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Pricing information section
          Text(
            AppLocalizations.of(context).pricingInformation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PricingRow(
                    label: AppLocalizations.of(context).currentMilkPrice,
                    value: 'TZS 800 / ${AppLocalizations.of(context).liter}',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).priceVariesByQuality,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Account actions section
          Text(
            AppLocalizations.of(context).account,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.orange.shade600,
                  ),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red.shade600,
                  ),
                  title: Text(
                    AppLocalizations.of(context).logout,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // App version
          Center(
            child: Text(
              '${AppLocalizations.of(context).version} 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getUserInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'F';
    }

    final parts = displayName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'sw':
        return 'Kiswahili';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Kiswahili'),
              value: 'sw',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).logout),
        content: Text(AppLocalizations.of(context).confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              final signOut = ref.read(signOutProvider);
              await signOut();
              if (context.mounted) {
                Navigator.pop(context);
                // Navigate to login screen
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text(
              AppLocalizations.of(context).logout,
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PricingRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
