import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/usecases/add_stock.dart';
import 'package:livestock/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:livestock/features/inventory/domain/usecases/get_stock_transactions.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

// Use case providers
final addStockUseCaseProvider = FutureProvider<AddStock>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return AddStock(repository);
});

final adjustStockUseCaseProvider = FutureProvider<AdjustStock>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return AdjustStock(repository);
});

final getStockTransactionsUseCaseProvider = FutureProvider<GetStockTransactions>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetStockTransactions(repository);
});

// Transaction type filter notifier
class TransactionTypeFilterNotifier extends Notifier<StockTransactionType?> {
  @override
  StockTransactionType? build() => null;

  void setType(StockTransactionType? type) {
    state = type;
  }

  void clear() {
    state = null;
  }
}

final transactionTypeFilterProvider = NotifierProvider<TransactionTypeFilterNotifier, StockTransactionType?>(() {
  return TransactionTypeFilterNotifier();
});

// Stock transactions provider for a product
final stockTransactionsProvider =
    FutureProvider.family<List<StockTransaction>, String>((ref, productId) async {
  final useCase = await ref.watch(getStockTransactionsUseCaseProvider.future);
  final typeFilter = ref.watch(transactionTypeFilterProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return [];
  }

  return await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    productId: productId,
    type: typeFilter,
  );
});

// Add stock state provider for form management
class AddStockState {
  final String? productId;
  final double? quantity;
  final String? reason;
  final bool isLoading;
  final String? error;

  AddStockState({
    this.productId,
    this.quantity,
    this.reason,
    this.isLoading = false,
    this.error,
  });

  AddStockState copyWith({
    String? productId,
    double? quantity,
    String? reason,
    bool? isLoading,
    String? error,
  }) {
    return AddStockState(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddStockStateNotifier extends Notifier<AddStockState> {
  @override
  AddStockState build() {
    return AddStockState();
  }

  void setProductId(String productId) {
    state = state.copyWith(productId: productId, error: null);
  }

  void setQuantity(double quantity) {
    state = state.copyWith(quantity: quantity, error: null);
  }

  void setReason(String? reason) {
    state = state.copyWith(reason: reason, error: null);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = AddStockState();
  }
}

final addStockStateProvider =
    NotifierProvider<AddStockStateNotifier, AddStockState>(() {
  return AddStockStateNotifier();
});

// Adjust stock state provider for form management
class AdjustStockState {
  final String? productId;
  final double? newStock;
  final String? reason;
  final bool isLoading;
  final String? error;

  AdjustStockState({
    this.productId,
    this.newStock,
    this.reason,
    this.isLoading = false,
    this.error,
  });

  AdjustStockState copyWith({
    String? productId,
    double? newStock,
    String? reason,
    bool? isLoading,
    String? error,
  }) {
    return AdjustStockState(
      productId: productId ?? this.productId,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdjustStockStateNotifier extends Notifier<AdjustStockState> {
  @override
  AdjustStockState build() {
    return AdjustStockState();
  }

  void setProductId(String productId) {
    state = state.copyWith(productId: productId, error: null);
  }

  void setNewStock(double newStock) {
    state = state.copyWith(newStock: newStock, error: null);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason, error: null);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = AdjustStockState();
  }
}

final adjustStockStateProvider =
    NotifierProvider<AdjustStockStateNotifier, AdjustStockState>(() {
  return AdjustStockStateNotifier();
});
