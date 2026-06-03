import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_providers.dart';

/// State for policy list
class PolicyListState {
  final List<InsurancePolicy> policies;
  final PolicyStatus? filterStatus;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const PolicyListState({
    this.policies = const [],
    this.filterStatus,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  PolicyListState copyWith({
    List<InsurancePolicy>? policies,
    PolicyStatus? filterStatus,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return PolicyListState(
      policies: policies ?? this.policies,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get filtered policies based on status and search query
  List<InsurancePolicy> get filteredPolicies {
    var filtered = policies;

    // Filter by status
    if (filterStatus != null) {
      filtered = filtered.where((p) => p.status == filterStatus).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.farmerId.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.id.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }
}

/// Notifier for policy list
class PolicyListNotifier extends Notifier<PolicyListState> {
  @override
  PolicyListState build() {
    return const PolicyListState();
  }

  /// Load policies for a farmer
  Future<void> loadPolicies(
    String farmerId, {
    required String cooperativeId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final useCase = ref.read(getFarmerPoliciesUseCaseProvider(cooperativeId));

    final result = await useCase(farmerId);

    switch (result) {
      case Success(value: final policies):
        state = state.copyWith(
          isLoading: false,
          policies: policies,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
    }
  }

  /// Filter by status
  void filterByStatus(PolicyStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  /// Search policies
  void searchPolicies(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Refresh policies
  Future<void> refresh(
    String farmerId, {
    required String cooperativeId,
    required String collectionCentreId,
  }) async {
    await loadPolicies(
      farmerId,
      cooperativeId: cooperativeId,
    );
  }
}

/// Provider for policy list state
final policyListProvider = NotifierProvider<PolicyListNotifier, PolicyListState>(
  PolicyListNotifier.new,
);
