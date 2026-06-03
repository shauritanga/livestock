import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/routes/app_router.dart';
import 'package:livestock/l10n/app_localizations.dart';
import 'package:livestock/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:livestock/features/inventory/presentation/screens/sales_screen.dart';

/// More menu screen providing access to secondary activities
class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).more),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // BUSINESS SECTION
          _buildSectionHeader(AppLocalizations.of(context).business),
          _buildMenuItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: AppLocalizations.of(context).inventory,
            subtitle: AppLocalizations.of(context).inventorySubtitle,
            iconColor: Colors.teal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InventoryListScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.point_of_sale_outlined,
            title: AppLocalizations.of(context).sales,
            subtitle: AppLocalizations.of(context).salesSubtitle,
            iconColor: Colors.indigo,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SalesScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.business_outlined,
            title: AppLocalizations.of(context).offTakers,
            subtitle: AppLocalizations.of(context).offTakersSubtitle,
            iconColor: Colors.deepPurple,
            onTap: () {
              context.push('/off-takers');
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.login_outlined,
            title: AppLocalizations.of(context).entrance,
            subtitle: AppLocalizations.of(context).entranceSubtitle,
            iconColor: Colors.cyan,
            onTap: () => context.push(AppRoutes.entranceFee),
          ),
          _buildMenuItem(
            context,
            icon: Icons.receipt_outlined,
            title: AppLocalizations.of(context).expenses,
            subtitle: AppLocalizations.of(context).expensesSubtitle,
            iconColor: Colors.red,
            onTap: () => context.push(AppRoutes.expenses),
          ),
          _buildMenuItem(
            context,
            icon: Icons.pets_outlined,
            title: AppLocalizations.of(context).cattle,
            subtitle: AppLocalizations.of(context).viewManageCattle,
            iconColor: Colors.brown,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cattle tracking feature coming soon')),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // FINANCIAL SERVICES SECTION
          _buildSectionHeader(AppLocalizations.of(context).financialServices),
          _buildMenuItem(
            context,
            icon: Icons.shield_outlined,
            title: AppLocalizations.of(context).insurance,
            subtitle: AppLocalizations.of(context).insuranceSubtitle,
            iconColor: Colors.blue,
            onTap: () => context.push(AppRoutes.insurance),
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance_outlined,
            title: AppLocalizations.of(context).loans,
            subtitle: AppLocalizations.of(context).loansSubtitle,
            iconColor: Colors.green,
            onTap: () => context.push(AppRoutes.loans),
          ),
          
          const SizedBox(height: 16),
          
          // RECORDS SECTION
          _buildSectionHeader(AppLocalizations.of(context).records),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: AppLocalizations.of(context).history,
            subtitle: AppLocalizations.of(context).historySubtitle,
            iconColor: Colors.orange,
            onTap: () => context.push(AppRoutes.history),
          ),
          
          const SizedBox(height: 16),
          
          // ACCOUNT SECTION
          _buildSectionHeader(AppLocalizations.of(context).account),
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context).profile,
            subtitle: AppLocalizations.of(context).profileSubtitle,
            iconColor: Colors.purple,
            onTap: () => context.push(AppRoutes.profile),
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: AppLocalizations.of(context).settings,
            subtitle: AppLocalizations.of(context).settingsSubtitle,
            iconColor: Colors.grey[700],
            onTap: () => context.push(AppRoutes.settings),
          ),
          _buildMenuItem(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Debug Tools',
            subtitle: 'Development and testing tools',
            iconColor: Colors.deepOrange,
            onTap: () => context.push('/debug'),
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
