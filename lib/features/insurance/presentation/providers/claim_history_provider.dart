import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_providers.dart';

/// State for claim history
class ClaimHistoryState {
  final List<InsuranceClaim> claims;
  final bool isLoading;
  final String? error;

  const ClaimHistoryState({
    this.claims = const [],
    this.isLoading = false,
    this.error,
  });

  ClaimHistoryState copyWith({
    List<InsuranceClaim>? claims,
    bool? isLoading,
    String? error,
  }) {
    return ClaimHistoryState(
      claims: claims ?? this.claims,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get pending claims
  List<InsuranceClaim> get pendingClaims {
    return claims.where((c) => c.isPending).toList();
  }

  /// Get approved claims
  List<InsuranceClaim> get approvedClaims {
    return claims.where((c) => c.isApproved).toList();
  }

  /// Get settled claims
  List<InsuranceClaim> get settledClaims {
    return claims.where((c) => c.isSettled).toList();
  }

  /// Get rejected claims
  List<InsuranceClaim> get rejectedClaims {
    return claims.where((c) => c.isRejected).toList();
  }
}

/// Notifier for claim history
class ClaimHistoryNotifier extends Notifier<ClaimHistoryState> {
  @override
  ClaimHistoryState build() {
    return const ClaimHistoryState();
  }

  /// Load claims for a farmer
  Future<void> loadClaims(
    String farmerId, {
    required String cooperativeId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final useCase = ref.read(getFarmerClaimsUseCaseProvider(cooperativeId));

    final result = await useCase(farmerId);

    switch (result) {
      case Success(value: final claims):
        state = state.copyWith(
          isLoading: false,
          claims: claims,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
    }
  }

  /// Refresh claims
  Future<void> refresh(
    String farmerId, {
    required String cooperativeId,
  }) async {
    await loadClaims(
      farmerId,
      cooperativeId: cooperativeId,
    );
  }
}

/// Provider for claim history state
final claimHistoryProvider = NotifierProvider<ClaimHistoryNotifier, ClaimHistoryState>(
  ClaimHistoryNotifier.new,
);
