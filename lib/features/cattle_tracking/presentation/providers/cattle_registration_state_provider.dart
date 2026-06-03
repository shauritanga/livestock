import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/register_cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/providers/cattle_providers.dart';

/// State for cattle registration
class CattleRegistrationState {
  final bool isLoading;
  final String? errorMessage;
  final Cattle? registeredCattle;

  const CattleRegistrationState({
    this.isLoading = false,
    this.errorMessage,
    this.registeredCattle,
  });

  CattleRegistrationState copyWith({
    bool? isLoading,
    String? errorMessage,
    Cattle? registeredCattle,
  }) {
    return CattleRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      registeredCattle: registeredCattle ?? this.registeredCattle,
    );
  }
}

/// Notifier for cattle registration
class CattleRegistrationNotifier extends Notifier<CattleRegistrationState> {
  late final RegisterCattle _registerCattleUseCase;

  @override
  CattleRegistrationState build() {
    _registerCattleUseCase = ref.read(registerCattleUseCaseProvider);
    return const CattleRegistrationState();
  }

  Future<void> registerCattle(Cattle cattle) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _registerCattleUseCase.call(cattle);

    switch (result) {
      case Success(value: final registeredCattle):
        state = state.copyWith(
          isLoading: false,
          registeredCattle: registeredCattle,
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
    state = const CattleRegistrationState();
  }
}

/// Provider for cattle registration state
final cattleRegistrationProvider =
    NotifierProvider<CattleRegistrationNotifier, CattleRegistrationState>(
  CattleRegistrationNotifier.new,
);
