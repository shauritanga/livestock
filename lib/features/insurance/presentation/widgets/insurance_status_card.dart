import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/policy_list_provider.dart';
import 'package:livestock/features/insurance/presentation/screens/insurance_enrollment_screen.dart';
import 'package:livestock/features/insurance/presentation/screens/policy_details_screen.dart';

/// Task 13.1: Insurance status card widget for farmer dashboard
///
/// Displays:
/// - Active policy indicator
/// - Covered cattle count
/// - Next premium due date and amount
/// - "View Policy" button or "Get Insurance" prompt
///
/// Requirements: 3.1
class InsuranceStatusCard extends ConsumerStatefulWidget {
  final String farmerId;

  const InsuranceStatusCard({
    super.key,
    required this.farmerId,
  });

  @override
  ConsumerState<InsuranceStatusCard> createState() =>
      _InsuranceStatusCardState();
}

class _InsuranceStatusCardState extends ConsumerState<InsuranceStatusCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolicies();
    });
  }

  void _loadPolicies() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    ref.read(policyListProvider.notifier).loadPolicies(
          widget.farmerId,
          cooperativeId: user.cooperativeId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final policyState = ref.watch(policyListProvider);

    // Get active policy
    final activePolicy = policyState.policies
        .where((p) => p.status == PolicyStatus.active)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.shield,
                  color: activePolicy != null
                      ? Colors.green.shade600
                      : Colors.grey.shade400,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insurance Coverage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activePolicy != null ? 'Active' : 'Not Enrolled',
                        style: TextStyle(
                          fontSize: 13,
                          color: activePolicy != null
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (policyState.isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ] else if (activePolicy != null) ...[
              // Active policy information
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Covered cattle count
              _buildInfoRow(
                context,
                icon: Icons.pets,
                label: 'Covered Cattle',
                value: '${activePolicy.coveredCattleIds.length} cattle',
              ),
              const SizedBox(height: 12),

              // Next payment due
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Next Payment Due',
                value: DateFormat('MMM d, y').format(activePolicy.nextPaymentDue),
                highlight: activePolicy.isPaymentOverdue,
              ),
              const SizedBox(height: 12),

              // Outstanding premium
              _buildInfoRow(
                context,
                icon: Icons.payments,
                label: 'Outstanding Premium',
                value: 'KES ${activePolicy.outstandingPremium.toStringAsFixed(0)}',
                highlight: activePolicy.outstandingPremium > 0,
              ),

              // Warning for overdue payment
              if (activePolicy.isPaymentOverdue) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment overdue',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // View Policy button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PolicyDetailsScreen(
                          policyId: activePolicy.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Policy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              // No active policy - prompt to get insurance
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Active Insurance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Protect your livestock with insurance coverage',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const InsuranceEnrollmentScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Get Insurance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: highlight ? Colors.red.shade600 : Colors.grey.shade600,
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
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: highlight ? Colors.red.shade600 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
