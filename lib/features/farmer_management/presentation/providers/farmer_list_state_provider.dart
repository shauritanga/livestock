import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/usecases/list_farmers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';

/// State for farmer list
class FarmerListState {
  final bool isLoading;
  final String? errorMessage;
  final List<Farmer> farmers;
  final String? searchQuery;

  const FarmerListState({
    this.isLoading = false,
    this.errorMessage,
    this.farmers = const [],
    this.searchQuery,
  });

  FarmerListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Farmer>? farmers,
    String? searchQuery,
  }) {
    return FarmerListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      farmers: farmers ?? this.farmers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for farmer list
class FarmerListNotifier extends Notifier<FarmerListState> {
  late final ListFarmers _listFarmersUseCase;

  @override
  FarmerListState build() {
    _listFarmersUseCase = ref.read(listFarmersUseCaseProvider);
    return const FarmerListState();
  }

  Future<void> loadFarmersByCooperative(
    String cooperativeId, {
    String? searchQuery,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: searchQuery,
    );

    final result = await _listFarmersUseCase.callByCooperative(
      cooperativeId,
      searchQuery: searchQuery,
    );

    switch (result) {
      case Success(value: final farmers):
        state = state.copyWith(
          isLoading: false,
          farmers: farmers,
          errorMessage: null,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  @Deprecated('Use loadFarmersByCooperative() instead. Collection centres have been removed.')
  Future<void> loadFarmersByCollectionCentre(
    String collectionCentreId, {
    String? searchQuery,
  }) async {
    // Redirect to cooperative-level query
    // This assumes collectionCentreId was actually a cooperativeId
    return loadFarmersByCooperative(
      collectionCentreId,
      searchQuery: searchQuery,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Provider for farmer list state
final farmerListProvider =
    NotifierProvider<FarmerListNotifier, FarmerListState>(
  FarmerListNotifier.new,
);
