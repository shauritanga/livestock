import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/policy_list_provider.dart';
import 'package:livestock/features/insurance/presentation/screens/policy_details_screen.dart';

/// Policy list screen for viewing all insurance policies
///
/// This screen allows collection agents to:
/// - View all insurance policies
/// - Search policies by farmer name
/// - Filter policies by status
/// - Navigate to policy details
///
/// Requirements: 3.2
class PolicyListScreen extends ConsumerStatefulWidget {
  const PolicyListScreen({super.key});

  @override
  ConsumerState<PolicyListScreen> createState() => _PolicyListScreenState();
}

class _PolicyListScreenState extends ConsumerState<PolicyListScreen> {
  final _searchController = TextEditingController();
  PolicyStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolicies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPolicies() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    // For now, we'll load policies for all farmers
    // In a real implementation, this would be a separate endpoint
    // that fetches all policies for the collection centre/cooperative
    
    // TODO: Implement proper policy loading
    // This is a placeholder - actual implementation would need
    // a use case to fetch all policies for a collection centre
  }

  void _handleSearch(String query) {
    ref.read(policyListProvider.notifier).searchPolicies(query);
  }

  void _handleFilterChange(PolicyStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    ref.read(policyListProvider.notifier).filterByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final policyState = ref.watch(policyListProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insurance Policies')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Policies'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPolicies,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Task 9.2: Search and filter section
          _buildSearchAndFilter(context, policyState),

          // Task 9.3 & 9.4: Policy list with loading/empty/error states
          Expanded(
            child: _buildPolicyList(context, policyState, user),
          ),
        ],
      ),
    );
  }

  /// Task 9.2: Build search and filter section
  Widget _buildSearchAndFilter(
    BuildContext context,
    PolicyListState policyState,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by farmer name or policy number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          _handleSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onSelected: () => _handleFilterChange(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active',
                  isSelected: _selectedStatus == PolicyStatus.active,
                  onSelected: () => _handleFilterChange(PolicyStatus.active),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Expired',
                  isSelected: _selectedStatus == PolicyStatus.expired,
                  onSelected: () => _handleFilterChange(PolicyStatus.expired),
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Suspended',
                  isSelected: _selectedStatus == PolicyStatus.suspended,
                  onSelected: () => _handleFilterChange(PolicyStatus.suspended),
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Cancelled',
                  isSelected: _selectedStatus == PolicyStatus.cancelled,
                  onSelected: () => _handleFilterChange(PolicyStatus.cancelled),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: (color ?? Theme.of(context).colorScheme.primary)
          .withOpacity(0.2),
      checkmarkColor: color ?? Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? (color ?? Theme.of(context).colorScheme.primary)
            : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Task 9.3 & 9.4: Build policy list with states
  Widget _buildPolicyList(
    BuildContext context,
    PolicyListState policyState,
    dynamic user,
  ) {
    // Task 9.4: Loading state
    if (policyState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Task 9.4: Error state
    if (policyState.error != null) {
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
                'Failed to load policies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                policyState.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPolicies,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Task 9.4: Empty state
    if (policyState.filteredPolicies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                policyState.searchQuery.isNotEmpty ||
                        policyState.filterStatus != null
                    ? 'No policies found'
                    : 'No insurance policies yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                policyState.searchQuery.isNotEmpty ||
                        policyState.filterStatus != null
                    ? 'Try adjusting your search or filters'
                    : 'Enroll farmers in insurance to see policies here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Task 9.3: Policy list
    return RefreshIndicator(
      onRefresh: () async {
        _loadPolicies();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: policyState.filteredPolicies.length,
        itemBuilder: (context, index) {
          final policy = policyState.filteredPolicies[index];
          return PolicyCard(
            policy: policy,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PolicyDetailsScreen(
                    policyId: policy.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Task 9.3: Policy card widget
class PolicyCard extends ConsumerWidget {
  final InsurancePolicy policy;
  final VoidCallback onTap;

  const PolicyCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try to get farmer name from farmer list
    final farmerListState = ref.watch(farmerListProvider);
    final farmer = farmerListState.farmers
        .where((f) => f.id == policy.farmerId)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with farmer name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer?.name ?? 'Farmer ${policy.farmerId.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Policy #${policy.id.substring(0, 12)}',
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
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Policy details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      icon: Icons.pets,
                      label: 'Covered Cattle',
                      value: '${policy.coveredCattleIds.length}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Next Payment',
                      value: _formatDate(policy.nextPaymentDue),
                      highlight: policy.isPaymentOverdue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Outstanding premium
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: policy.outstandingPremium > 0
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: policy.outstandingPremium > 0
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outstanding Premium',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'KES ${policy.outstandingPremium.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: policy.outstandingPremium > 0
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: highlight ? Colors.red.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.red.shade600 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}
