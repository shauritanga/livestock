import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/providers/cattle_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_enrollment_provider.dart';
import 'package:livestock/core/utils/result.dart';

/// Insurance enrollment screen for enrolling farmers in livestock insurance
///
/// This screen allows collection agents to:
/// - Select a farmer for enrollment
/// - Choose cattle to cover
/// - Calculate premiums
/// - Select payment frequency
/// - Complete enrollment
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7
class InsuranceEnrollmentScreen extends ConsumerStatefulWidget {
  const InsuranceEnrollmentScreen({super.key});

  @override
  ConsumerState<InsuranceEnrollmentScreen> createState() =>
      _InsuranceEnrollmentScreenState();
}

class _InsuranceEnrollmentScreenState
    extends ConsumerState<InsuranceEnrollmentScreen> {
  final _searchController = TextEditingController();
  bool _showFarmerSearch = false;
  List<Cattle> _farmerCattle = [];
  bool _loadingCattle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarmers() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    if (user.role.name == 'collection_agent' &&
        user.collectionCentreId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCollectionCentre(
            user.collectionCentreId!,
          );
    } else if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
          );
    }
  }

  Future<void> _loadFarmerCattle(String farmerId) async {
    setState(() {
      _loadingCattle = true;
    });

    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    final useCase = ref.read(listFarmerCattleUseCaseProvider);
    final result = await useCase(farmerId);

    switch (result) {
      case Success(value: final cattle):
        setState(() {
          _farmerCattle = cattle;
          _loadingCattle = false;
        });
      case Error():
        setState(() {
          _farmerCattle = [];
          _loadingCattle = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load farmer cattle'),
            ),
          );
        }
    }
  }

  void _selectFarmer(Farmer farmer) {
    ref
        .read(insuranceEnrollmentProvider.notifier)
        .selectFarmer(farmer, _farmerCattle);
    setState(() {
      _showFarmerSearch = false;
    });
    _loadFarmerCattle(farmer.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final enrollmentState = ref.watch(insuranceEnrollmentProvider);
    final farmerListState = ref.watch(farmerListProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enroll in Insurance')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    // Show success dialog
    if (enrollmentState.enrollmentSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll in Insurance'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Task 8.2: Farmer selection section
                _buildFarmerSelectionSection(
                  context,
                  enrollmentState,
                  farmerListState,
                ),
                const SizedBox(height: 16),

                // Task 8.3: Cattle selection section
                if (enrollmentState.selectedFarmer != null)
                  _buildCattleSelectionSection(
                    context,
                    enrollmentState,
                    user,
                  ),

                // Task 8.4: Premium calculation display
                if (enrollmentState.premiumCalculation != null) ...[
                  const SizedBox(height: 16),
                  _buildPremiumCalculationSection(
                    context,
                    enrollmentState,
                  ),
                ],

                // Task 8.5: Payment frequency selector
                if (enrollmentState.selectedCattleIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildPaymentFrequencySection(
                    context,
                    enrollmentState,
                  ),
                ],

                // Task 8.6: Policy summary card
                if (enrollmentState.premiumCalculation != null) ...[
                  const SizedBox(height: 16),
                  _buildPolicySummarySection(
                    context,
                    enrollmentState,
                  ),
                ],

                const SizedBox(height: 24),

                // Task 8.7: Enrollment confirmation button
                if (enrollmentState.selectedFarmer != null &&
                    enrollmentState.selectedCattleIds.isNotEmpty &&
                    enrollmentState.premiumCalculation != null)
                  _buildEnrollmentButton(
                    context,
                    enrollmentState,
                    user,
                  ),

                // Error message
                if (enrollmentState.error != null) ...[
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
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            enrollmentState.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Farmer search overlay
          if (_showFarmerSearch)
            _buildFarmerSearchOverlay(context, farmerListState),

          // Loading overlay
          if (enrollmentState.isEnrolling)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Enrolling in insurance...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Task 8.2: Build farmer selection section
  Widget _buildFarmerSelectionSection(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
    dynamic farmerListState,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _showFarmerSearch = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: enrollmentState.selectedFarmer == null
              ? Row(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Farmer',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to search and select a farmer',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            enrollmentState.selectedFarmer!.name
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                enrollmentState.selectedFarmer!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                enrollmentState.selectedFarmer!.phoneNumber,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showFarmerSearch = true;
                            });
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    if (enrollmentState.selectedFarmer!.location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            enrollmentState.selectedFarmer!.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  /// Task 8.3: Build cattle selection section
  Widget _buildCattleSelectionSection(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
    dynamic user,
  ) {
    if (_loadingCattle) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_farmerCattle.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.pets_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No cattle registered',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This farmer has no registered cattle',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Cattle to Cover',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose cattle to include in the insurance policy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ..._farmerCattle.map((cattle) {
              final isSelected =
                  enrollmentState.selectedCattleIds.contains(cattle.id);
              final isProductive = cattle.isProductive;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                      : null,
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    ref
                        .read(insuranceEnrollmentProvider.notifier)
                        .toggleCattleSelection(
                          cattle.id,
                          cooperativeId: user.cooperativeId!,
                        );
                  },
                  title: Row(
                    children: [
                      Text(
                        'Cattle #${cattle.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isProductive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Productive',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${cattle.breed} • ${cattle.ageMonths} months • ${cattle.gender.name}',
                      ),
                      Text(
                        'Status: ${cattle.lactationStatus.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (enrollmentState.selectedCattleIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one cattle',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Task 8.4: Build premium calculation display
  Widget _buildPremiumCalculationSection(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
  ) {
    final calculation = enrollmentState.premiumCalculation!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Premium Calculation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...calculation.cattlePremiums.map((cattlePremium) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cattlePremium.cattleName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            cattlePremium.rateCategory,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'KES ${cattlePremium.premium.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Annual Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KES ${calculation.totalAnnualPremium.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Installment:'),
                      Text(
                        'KES ${calculation.monthlyInstallment.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quarterly Installment:'),
                      Text(
                        'KES ${calculation.quarterlyInstallment.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Task 8.5: Build payment frequency selector
  Widget _buildPaymentFrequencySection(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how often you want to pay premiums',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            RadioListTile<PaymentFrequency>(
              value: PaymentFrequency.monthly,
              groupValue: enrollmentState.selectedFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(insuranceEnrollmentProvider.notifier)
                      .selectFrequency(value);
                }
              },
              title: const Text('Monthly'),
              subtitle: enrollmentState.premiumCalculation != null
                  ? Text(
                      'KES ${enrollmentState.premiumCalculation!.monthlyInstallment.toStringAsFixed(0)} per month',
                    )
                  : null,
            ),
            RadioListTile<PaymentFrequency>(
              value: PaymentFrequency.quarterly,
              groupValue: enrollmentState.selectedFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(insuranceEnrollmentProvider.notifier)
                      .selectFrequency(value);
                }
              },
              title: const Text('Quarterly'),
              subtitle: enrollmentState.premiumCalculation != null
                  ? Text(
                      'KES ${enrollmentState.premiumCalculation!.quarterlyInstallment.toStringAsFixed(0)} every 3 months',
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Task 8.6: Build policy summary section
  Widget _buildPolicySummarySection(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
  ) {
    final calculation = enrollmentState.premiumCalculation!;
    final installmentAmount = enrollmentState.selectedFrequency ==
            PaymentFrequency.monthly
        ? calculation.monthlyInstallment
        : calculation.quarterlyInstallment;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Policy Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Farmer',
              enrollmentState.selectedFarmer!.name,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Covered Cattle',
              '${enrollmentState.selectedCattleIds.length} cattle',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Premium',
              'KES ${calculation.totalAnnualPremium.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Payment Frequency',
              enrollmentState.selectedFrequency.label,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Installment Amount',
              'KES ${installmentAmount.toStringAsFixed(0)}',
              highlight: true,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Policy Duration',
              '12 months',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            fontSize: highlight ? 16 : 14,
          ),
        ),
      ],
    );
  }

  /// Task 8.7: Build enrollment confirmation button
  Widget _buildEnrollmentButton(
    BuildContext context,
    InsuranceEnrollmentState enrollmentState,
    dynamic user,
  ) {
    return ElevatedButton.icon(
      onPressed: enrollmentState.isEnrolling
          ? null
          : () async {
              await ref
                  .read(insuranceEnrollmentProvider.notifier)
                  .enrollInsurance(
                    cooperativeId: user.cooperativeId!,
                  );
            },
      icon: const Icon(Icons.shield),
      label: const Text('Enroll in Insurance'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  /// Build farmer search overlay
  Widget _buildFarmerSearchOverlay(
    BuildContext context,
    dynamic farmerListState,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBar(
            title: const Text('Select Farmer'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showFarmerSearch = false;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Implement search
              },
            ),
          ),
          Expanded(
            child: farmerListState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : farmerListState.farmers.isEmpty
                    ? const Center(child: Text('No farmers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: farmerListState.farmers.length,
                        itemBuilder: (context, index) {
                          final farmer = farmerListState.farmers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  farmer.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                farmer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(farmer.phoneNumber),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () => _selectFarmer(farmer),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 64,
        ),
        title: const Text('Enrollment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The farmer has been successfully enrolled in livestock insurance.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Policy details have been sent via SMS.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(insuranceEnrollmentProvider.notifier).reset();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
