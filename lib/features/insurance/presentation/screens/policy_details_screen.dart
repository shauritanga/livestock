import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/policy_details_provider.dart';

/// Policy details screen for viewing detailed information about an insurance policy
///
/// This screen displays:
/// - Policy header with status and dates
/// - Covered cattle information
/// - Premium information
/// - Payment history
///
/// Requirements: 3.2, 3.3, 3.4, 7.1, 7.2
class PolicyDetailsScreen extends ConsumerStatefulWidget {
  final String policyId;

  const PolicyDetailsScreen({
    super.key,
    required this.policyId,
  });

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolicyDetails();
    });
  }

  void _loadPolicyDetails() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    ref.read(policyDetailsProvider.notifier).loadPolicyDetails(
          widget.policyId,
          cooperativeId: user.cooperativeId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final detailsState = ref.watch(policyDetailsProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Policy Details')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Policy #${widget.policyId.substring(0, 12)}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPolicyDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context, detailsState),
    );
  }

  Widget _buildBody(BuildContext context, PolicyDetailsState detailsState) {
    // Loading state
    if (detailsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (detailsState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load policy details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detailsState.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPolicyDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // No policy loaded
    if (detailsState.policy == null) {
      return const Center(
        child: Text('Policy not found'),
      );
    }

    final policy = detailsState.policy!;

    return RefreshIndicator(
      onRefresh: () async {
        _loadPolicyDetails();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task 10.2: Policy header section
            _buildPolicyHeader(context, policy),
            const SizedBox(height: 16),

            // Task 10.3: Covered cattle section
            _buildCoveredCattleSection(context, detailsState),
            const SizedBox(height: 16),

            // Task 10.4: Premium information section
            _buildPremiumInformationSection(context, policy),
            const SizedBox(height: 16),

            // Task 10.5: Payment history section
            _buildPaymentHistorySection(context, detailsState),
          ],
        ),
      ),
    );
  }

  /// Task 10.2: Build policy header section
  Widget _buildPolicyHeader(BuildContext context, InsurancePolicy policy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Policy #${policy.id.substring(0, 12)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Farmer ID: ${policy.farmerId.substring(0, 12)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, policy.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Policy dates
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    context,
                    label: 'Start Date',
                    date: policy.policyStartDate,
                  ),
                ),
                Expanded(
                  child: _buildDateInfo(
                    context,
                    label: 'End Date',
                    date: policy.policyEndDate,
                  ),
                ),
              ],
            ),

            // Days until expiry (if active)
            if (policy.isActive) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: policy.isExpiringSoon
                      ? Colors.orange.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: policy.isExpiringSoon
                        ? Colors.orange.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      policy.isExpiringSoon
                          ? Icons.warning_amber
                          : Icons.info_outline,
                      color: policy.isExpiringSoon
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        policy.daysUntilExpiry > 0
                            ? '${policy.daysUntilExpiry} days until policy expires'
                            : 'Policy expires today',
                        style: TextStyle(
                          color: policy.isExpiringSoon
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Renew button if expiring within 30 days
            if (policy.isExpiringSoon) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Policy renewal coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Renew Policy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Task 10.3: Build covered cattle section
  Widget _buildCoveredCattleSection(
    BuildContext context,
    PolicyDetailsState detailsState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Covered Cattle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (detailsState.coveredCattle.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No cattle information available',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ...detailsState.coveredCattle.map((cattle) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Cattle photo placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: cattle.muzzleImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cattle.muzzleImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.pets,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.pets,
                                size: 32,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cattle #${cattle.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cattle.breed} • ${cattle.ageMonths} months • ${cattle.gender.name}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cattle.isProductive
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    cattle.lactationStatus.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cattle.isProductive
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Task 10.4: Build premium information section
  Widget _buildPremiumInformationSection(
    BuildContext context,
    InsurancePolicy policy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Premium Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPremiumRow(
              'Total Premium',
              'KES ${policy.totalPremium.toStringAsFixed(0)}',
              bold: true,
            ),
            const SizedBox(height: 12),
            _buildPremiumRow(
              'Payment Frequency',
              policy.paymentFrequency.label,
            ),
            const SizedBox(height: 12),
            _buildPremiumRow(
              'Installment Amount',
              'KES ${policy.installmentAmount.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildPremiumRow(
              'Total Paid',
              'KES ${policy.totalPaid.toStringAsFixed(0)}',
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 12),
            _buildPremiumRow(
              'Outstanding Balance',
              'KES ${policy.outstandingPremium.toStringAsFixed(0)}',
              valueColor: policy.outstandingPremium > 0
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              bold: true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: policy.isPaymentOverdue
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: policy.isPaymentOverdue
                      ? Colors.red.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Payment Due',
                    style: TextStyle(
                      fontSize: 14,
                      color: policy.isPaymentOverdue
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(policy.nextPaymentDue),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: policy.isPaymentOverdue
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Task 10.5: Build payment history section
  Widget _buildPaymentHistorySection(
    BuildContext context,
    PolicyDetailsState detailsState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (detailsState.paymentHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No payments recorded yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ...detailsState.paymentHistory.map((payment) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, y').format(payment.paymentDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'KES ${payment.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(payment.paymentMethod),
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            payment.paymentMethod.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Link to milk delivery if applicable
                      if (payment.isFromMilkDeduction &&
                          payment.milkDeliveryId != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'View milk delivery: ${payment.milkDeliveryId}',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'View linked milk delivery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PolicyStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case PolicyStatus.active:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case PolicyStatus.expired:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case PolicyStatus.suspended:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case PolicyStatus.cancelled:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context, {
    required String label,
    required DateTime date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM d, y').format(date),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.milkDeduction:
        return Icons.water_drop;
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
    }
  }
}
