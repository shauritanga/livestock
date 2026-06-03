import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_providers.dart';

/// State for policy details
class PolicyDetailsState {
  final InsurancePolicy? policy;
  final List<Cattle> coveredCattle;
  final List<PremiumPayment> paymentHistory;
  final bool isLoading;
  final String? error;

  const PolicyDetailsState({
    this.policy,
    this.coveredCattle = const [],
    this.paymentHistory = const [],
    this.isLoading = false,
    this.error,
  });

  PolicyDetailsState copyWith({
    InsurancePolicy? policy,
    List<Cattle>? coveredCattle,
    List<PremiumPayment>? paymentHistory,
    bool? isLoading,
    String? error,
  }) {
    return PolicyDetailsState(
      policy: policy ?? this.policy,
      coveredCattle: coveredCattle ?? this.coveredCattle,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for policy details
class PolicyDetailsNotifier extends Notifier<PolicyDetailsState> {
  @override
  PolicyDetailsState build() {
    return const PolicyDetailsState();
  }

  /// Load policy details
  Future<void> loadPolicyDetails(
    String policyId, {
    required String cooperativeId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final useCase = ref.read(getPolicyDetailsUseCaseProvider(cooperativeId));

    final result = await useCase(policyId);

    switch (result) {
      case Success(value: final details):
        state = state.copyWith(
          isLoading: false,
          policy: details.policy,
          coveredCattle: details.coveredCattle,
          paymentHistory: details.paymentHistory,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
    }
  }

  /// Refresh policy details
  Future<void> refresh(
    String policyId, {
    required String cooperativeId,
    required String collectionCentreId,
  }) async {
    await loadPolicyDetails(
      policyId,
      cooperativeId: cooperativeId,
    );
  }
}

/// Provider for policy details state
final policyDetailsProvider = NotifierProvider<PolicyDetailsNotifier, PolicyDetailsState>(
  PolicyDetailsNotifier.new,
);
