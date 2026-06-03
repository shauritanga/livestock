import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

/// Loans screen for accessing financial services
/// 
/// Integrates with insurance verification to ensure farmers have
/// active insurance coverage before applying for loans
class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loans),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 100,
                color: Colors.green[300],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.financialServices,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Access loans and financial support for your farming needs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.trending_up,
                        title: 'Low Interest Rates',
                        description: 'Competitive rates for farmers',
                      ),
                      const Divider(),
                      _buildFeatureItem(
                        icon: Icons.schedule,
                        title: 'Flexible Repayment',
                        description: 'Payment plans that work for you',
                      ),
                      const Divider(),
                      _buildFeatureItem(
                        icon: Icons.speed,
                        title: 'Quick Approval',
                        description: 'Fast processing and disbursement',
                      ),
                      const Divider(),
                      _buildFeatureItem(
                        icon: Icons.security,
                        title: l10n.insuranceRequired,
                        description: l10n.allProductiveCattleMustBeInsured,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _handleLoanApplication(context, l10n),
                icon: const Icon(Icons.add),
                label: Text(l10n.loans),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoanApplication(BuildContext context, AppLocalizations l10n) {
    // Show insurance requirement dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Text(l10n.insuranceRequired),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.allProductiveCattleMustBeInsured),
            const SizedBox(height: 16),
            Text(
              'To apply for a loan, you must:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRequirement('Have an active insurance policy'),
            _buildRequirement('All productive cattle must be insured'),
            _buildRequirement('No overdue premium payments'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to insurance enrollment
              context.push('/insurance');
            },
            icon: const Icon(Icons.security),
            label: Text(l10n.getInsuranceNow),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description),
    );
  }
}
