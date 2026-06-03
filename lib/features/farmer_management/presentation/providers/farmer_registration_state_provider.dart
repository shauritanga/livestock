import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/usecases/register_farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';

/// State for farmer registration
class FarmerRegistrationState {
  final bool isLoading;
  final String? errorMessage;
  final Farmer? registeredFarmer;
  final int currentStep;

  const FarmerRegistrationState({
    this.isLoading = false,
    this.errorMessage,
    this.registeredFarmer,
    this.currentStep = 0,
  });

  FarmerRegistrationState copyWith({
    bool? isLoading,
    String? errorMessage,
    Farmer? registeredFarmer,
    int? currentStep,
  }) {
    return FarmerRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      registeredFarmer: registeredFarmer ?? this.registeredFarmer,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// Notifier for farmer registration
class FarmerRegistrationNotifier extends Notifier<FarmerRegistrationState> {
  late final RegisterFarmer _registerFarmerUseCase;

  @override
  FarmerRegistrationState build() {
    _registerFarmerUseCase = ref.read(registerFarmerUseCaseProvider);
    return const FarmerRegistrationState();
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> registerFarmer(Farmer farmer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _registerFarmerUseCase.call(farmer);

    switch (result) {
      case Success(value: final registeredFarmer):
        state = state.copyWith(
          isLoading: false,
          registeredFarmer: registeredFarmer,
          errorMessage: null,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  void reset() {
    state = const FarmerRegistrationState();
  }
}

/// Provider for farmer registration state
final farmerRegistrationProvider =
    NotifierProvider<FarmerRegistrationNotifier, FarmerRegistrationState>(
  FarmerRegistrationNotifier.new,
);
