import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/core/providers/locale_provider.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkThemeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLanguage = ref.watch(localeDisplayNameProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // GENERAL SECTION
          _buildSectionHeader(l10n.general),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.notificationsSubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.notificationSettingsComingSoon)),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: currentLanguage,
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: l10n.darkTheme,
            subtitle: l10n.darkThemeSubtitle,
            trailing: Switch(
              value: _darkThemeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkThemeEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? l10n.darkThemeEnabled : l10n.darkThemeDisabled),
                  ),
                );
              },
            ),
            onTap: null,
          ),
          
          const SizedBox(height: 16),
          
          // PRIVACY & SECURITY SECTION
          _buildSectionHeader(l10n.privacySecurity),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: l10n.privacy,
            subtitle: l10n.privacySubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.privacySettingsComingSoon)),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: l10n.security,
            subtitle: l10n.securitySubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.securitySettingsComingSoon)),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // SUPPORT SECTION
          _buildSectionHeader(l10n.support),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: l10n.helpSupport,
            subtitle: l10n.helpSupportSubtitle,
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.aboutSubtitle,
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          
          const SizedBox(height: 16),
          
          // ACCOUNT SECTION
          _buildSectionHeader(l10n.account),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: l10n.logOut,
            subtitle: null,
            titleColor: Colors.blue,
            iconColor: Colors.blue,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.delete_outline,
            title: l10n.deleteAccount,
            subtitle: null,
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English (US)',
              const Locale('en', ''),
              currentLocale,
            ),
            _buildLanguageOption(
              context,
              'Kiswahili',
              const Locale('sw', ''),
              currentLocale,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
    Locale currentLocale,
  ) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    
    return ListTile(
      title: Text(label),
      leading: isSelected 
        ? const Icon(Icons.check, color: Colors.green)
        : const SizedBox(width: 24),
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.helpSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.needHelp),
            const SizedBox(height: 16),
            Text(l10n.supportEmail),
            const SizedBox(height: 8),
            Text(l10n.supportPhone),
            const SizedBox(height: 8),
            Text(l10n.supportHours),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.version}: 1.0.0'),
            const SizedBox(height: 8),
            Text('${l10n.build}: 100'),
            const SizedBox(height: 16),
            Text(l10n.appDescription),
            const SizedBox(height: 8),
            Text(l10n.copyright),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.logOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref.read(signOutProvider).call();
              if (context.mounted) {
                switch (result) {
                  case Success():
                    context.go('/login');
                  case Error(:final failure):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.logOutFailed}: ${failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              }
            },
            child: Text(l10n.logOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deleteAccountComingSoon),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
