import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Farmer Insurance Details Screen - Shows insurance policies and claims
class FarmerInsuranceDetailsScreen extends ConsumerWidget {
  const FarmerInsuranceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).insurance),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active policy card
          _ActivePolicyCard(),
          const SizedBox(height: 24),
          
          // Covered cattle section
          Text(
            AppLocalizations.of(context).coveredCattle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _CoveredCattleList(),
          const SizedBox(height: 24),
          
          // Claims history
          Text(
            AppLocalizations.of(context).claims,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ClaimsHistoryList(),
        ],
      ),
    );
  }
}

class _ActivePolicyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual policy data
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    color: Colors.blue.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).activePolicy,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Livestock Insurance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
              label: AppLocalizations.of(context).policyNumber,
              value: 'POL-2024-001',
            ),
            _DetailRow(
              label: AppLocalizations.of(context).premium,
              value: 'TZS 50,000 / ${AppLocalizations.of(context).month}',
            ),
            _DetailRow(
              label: AppLocalizations.of(context).coverage,
              value: 'TZS 2,000,000',
            ),
            _DetailRow(
              label: AppLocalizations.of(context).validUntil,
              value: DateFormat('MMM d, yyyy').format(DateTime.now().add(const Duration(days: 365))),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoveredCattleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual covered cattle
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppLocalizations.of(context).noCoveredCattle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClaimsHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual claims
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppLocalizations.of(context).noClaimsSubmitted,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
