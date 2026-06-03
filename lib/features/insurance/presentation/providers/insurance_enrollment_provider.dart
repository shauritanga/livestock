import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_providers.dart';

/// State for insurance enrollment
class InsuranceEnrollmentState {
  final Farmer? selectedFarmer;
  final List<Cattle> availableCattle;
  final List<String> selectedCattleIds;
  final PremiumCalculation? premiumCalculation;
  final PaymentFrequency selectedFrequency;
  final bool isCalculating;
  final bool isEnrolling;
  final String? error;
  final bool enrollmentSuccess;

  const InsuranceEnrollmentState({
    this.selectedFarmer,
    this.availableCattle = const [],
    this.selectedCattleIds = const [],
    this.premiumCalculation,
    this.selectedFrequency = PaymentFrequency.monthly,
    this.isCalculating = false,
    this.isEnrolling = false,
    this.error,
    this.enrollmentSuccess = false,
  });

  InsuranceEnrollmentState copyWith({
    Farmer? selectedFarmer,
    List<Cattle>? availableCattle,
    List<String>? selectedCattleIds,
    PremiumCalculation? premiumCalculation,
    PaymentFrequency? selectedFrequency,
    bool? isCalculating,
    bool? isEnrolling,
    String? error,
    bool? enrollmentSuccess,
  }) {
    return InsuranceEnrollmentState(
      selectedFarmer: selectedFarmer ?? this.selectedFarmer,
      availableCattle: availableCattle ?? this.availableCattle,
      selectedCattleIds: selectedCattleIds ?? this.selectedCattleIds,
      premiumCalculation: premiumCalculation ?? this.premiumCalculation,
      selectedFrequency: selectedFrequency ?? this.selectedFrequency,
      isCalculating: isCalculating ?? this.isCalculating,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      error: error,
      enrollmentSuccess: enrollmentSuccess ?? this.enrollmentSuccess,
    );
  }
}

/// Notifier for insurance enrollment
class InsuranceEnrollmentNotifier extends Notifier<InsuranceEnrollmentState> {
  @override
  InsuranceEnrollmentState build() {
    return const InsuranceEnrollmentState();
  }

  /// Select a farmer for enrollment
  void selectFarmer(Farmer farmer, List<Cattle> cattle) {
    state = state.copyWith(
      selectedFarmer: farmer,
      availableCattle: cattle,
      selectedCattleIds: [],
      premiumCalculation: null,
      error: null,
    );
  }

  /// Toggle cattle selection
  void toggleCattleSelection(
    String cattleId, {
    required String cooperativeId,
  }) {
    final currentSelection = List<String>.from(state.selectedCattleIds);

    if (currentSelection.contains(cattleId)) {
      currentSelection.remove(cattleId);
    } else {
      currentSelection.add(cattleId);
    }

    state = state.copyWith(
      selectedCattleIds: currentSelection,
      error: null,
    );

    // Auto-calculate premium when selection changes
    if (currentSelection.isNotEmpty && state.selectedFarmer != null) {
      calculatePremium(
        cooperativeId: cooperativeId,
      );
    } else {
      state = state.copyWith(premiumCalculation: null);
    }
  }

  /// Select payment frequency
  void selectFrequency(PaymentFrequency frequency) {
    state = state.copyWith(
      selectedFrequency: frequency,
      error: null,
    );
  }

  /// Calculate premium for selected cattle
  Future<void> calculatePremium({
    required String cooperativeId,
  }) async {
    if (state.selectedFarmer == null || state.selectedCattleIds.isEmpty) {
      return;
    }

    state = state.copyWith(
      isCalculating: true,
      error: null,
    );

    final useCase = ref.read(calculatePremiumUseCaseProvider(cooperativeId));

    final result = await useCase(
      farmerId: state.selectedFarmer!.id,
      cattleIds: state.selectedCattleIds,
    );

    switch (result) {
      case Success(value: final calculation):
        state = state.copyWith(
          isCalculating: false,
          premiumCalculation: calculation,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isCalculating: false,
          error: failure.message,
        );
    }
  }

  /// Enroll farmer in insurance
  Future<void> enrollInsurance({
    required String cooperativeId,
  }) async {
    if (state.selectedFarmer == null ||
        state.selectedCattleIds.isEmpty ||
        state.premiumCalculation == null) {
      state = state.copyWith(
        error: 'Please select farmer and cattle first',
      );
      return;
    }

    state = state.copyWith(
      isEnrolling: true,
      error: null,
    );

    final useCase = ref.read(enrollInsuranceUseCaseProvider(cooperativeId));

    final result = await useCase(
      farmerId: state.selectedFarmer!.id,
      cattleIds: state.selectedCattleIds,
      paymentFrequency: state.selectedFrequency,
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          isEnrolling: false,
          enrollmentSuccess: true,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isEnrolling: false,
          error: failure.message,
        );
    }
  }

  /// Reset state
  void reset() {
    state = const InsuranceEnrollmentState();
  }
}

/// Provider for insurance enrollment state
final insuranceEnrollmentProvider = NotifierProvider<InsuranceEnrollmentNotifier, InsuranceEnrollmentState>(
  InsuranceEnrollmentNotifier.new,
);
