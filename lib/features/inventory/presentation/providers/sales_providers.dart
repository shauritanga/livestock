import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/domain/usecases/get_sales.dart';
import 'package:livestock/features/inventory/domain/usecases/record_sale.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/milk_sales/presentation/providers/milk_sale_providers.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';

// Use case providers
final recordSaleUseCaseProvider = FutureProvider<RecordSale>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return RecordSale(repository);
});

final getSalesUseCaseProvider = FutureProvider<GetSales>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetSales(repository);
});

// Date range filter notifiers
class SalesStartDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) {
    state = date;
  }

  void clear() {
    state = null;
  }
}

class SalesEndDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) {
    state = date;
  }

  void clear() {
    state = null;
  }
}

class SalesProductIdFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setProductId(String? productId) {
    state = productId;
  }

  void clear() {
    state = null;
  }
}

final salesStartDateProvider = NotifierProvider<SalesStartDateNotifier, DateTime?>(() {
  return SalesStartDateNotifier();
});

final salesEndDateProvider = NotifierProvider<SalesEndDateNotifier, DateTime?>(() {
  return SalesEndDateNotifier();
});

final salesProductIdFilterProvider = NotifierProvider<SalesProductIdFilterNotifier, String?>(() {
  return SalesProductIdFilterNotifier();
});

// Sales provider with filtering (includes milk sales)
final salesProvider = FutureProvider<SalesSummary>((ref) async {
  final useCase = await ref.watch(getSalesUseCaseProvider.future);
  final startDate = ref.watch(salesStartDateProvider);
  final endDate = ref.watch(salesEndDateProvider);
  final productId = ref.watch(salesProductIdFilterProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return SalesSummary(sales: [], totalRevenue: 0, totalCount: 0);
  }

  // Get product sales
  final productSales = await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    startDate: startDate,
    endDate: endDate,
    productId: productId,
  );

  // Get milk sales
  try {
    final milkSalesRepo = ref.watch(milkSaleRepositoryProvider);
    final milkSales = startDate != null && endDate != null
        ? await milkSalesRepo.getSalesByDateRange(currentUser.cooperativeId!, startDate, endDate)
        : await milkSalesRepo.getSalesByCooperative(currentUser.cooperativeId!);

    // Convert milk sales to SaleTransaction
    final milkSaleTransactions = milkSales.map((ms) => SaleTransaction(
          id: ms.id,
          cooperativeId: ms.cooperativeId,
          productId: 'MILK-VIRTUAL',
          productName: 'Fresh Milk',
          quantity: ms.quantityLiters,
          unitPrice: ms.pricePerLiter,
          totalAmount: ms.totalAmount,
          customerName: ms.customerName,
          timestamp: ms.saleDate,
          processedBy: ms.recordedBy,
          notes: ms.customerName != null ? 'Milk sale to ${ms.customerName}' : 'Milk sale',
        )).toList();

    // Merge sales
    final allSales = [...productSales.sales, ...milkSaleTransactions];
    allSales.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by date descending

    return SalesSummary(
      sales: allSales,
      totalRevenue: productSales.totalRevenue + milkSales.fold<double>(0, (sum, ms) => sum + ms.totalAmount),
      totalCount: productSales.totalCount + milkSales.length,
    );
  } catch (e) {
    // If milk sales fail, just return product sales
    return productSales;
  }
});

// Sales summary providers for different periods (includes milk sales)
final todaySalesProvider = FutureProvider<SalesSummary>((ref) async {
  final useCase = await ref.watch(getSalesUseCaseProvider.future);
  final currentUser = ref.watch(currentAuthUserProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  if (currentUser?.cooperativeId == null) {
    return SalesSummary(sales: [], totalRevenue: 0, totalCount: 0);
  }

  final productSales = await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    startDate: startOfDay,
    endDate: endOfDay,
  );

  // Add milk sales
  try {
    final milkSalesRepo = ref.watch(milkSaleRepositoryProvider);
    final milkSales = await milkSalesRepo.getSalesByDateRange(currentUser.cooperativeId!, startOfDay, endOfDay);
    
    return SalesSummary(
      sales: productSales.sales,
      totalRevenue: productSales.totalRevenue + milkSales.fold<double>(0, (sum, ms) => sum + ms.totalAmount),
      totalCount: productSales.totalCount + milkSales.length,
    );
  } catch (e) {
    return productSales;
  }
});

final thisWeekSalesProvider = FutureProvider<SalesSummary>((ref) async {
  final useCase = await ref.watch(getSalesUseCaseProvider.future);
  final currentUser = ref.watch(currentAuthUserProvider);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  if (currentUser?.cooperativeId == null) {
    return SalesSummary(sales: [], totalRevenue: 0, totalCount: 0);
  }

  final productSales = await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    startDate: startDate,
    endDate: now,
  );

  // Add milk sales
  try {
    final milkSalesRepo = ref.watch(milkSaleRepositoryProvider);
    final milkSales = await milkSalesRepo.getSalesByDateRange(currentUser.cooperativeId!, startDate, now);
    
    return SalesSummary(
      sales: productSales.sales,
      totalRevenue: productSales.totalRevenue + milkSales.fold<double>(0, (sum, ms) => sum + ms.totalAmount),
      totalCount: productSales.totalCount + milkSales.length,
    );
  } catch (e) {
    return productSales;
  }
});

final thisMonthSalesProvider = FutureProvider<SalesSummary>((ref) async {
  final useCase = await ref.watch(getSalesUseCaseProvider.future);
  final currentUser = ref.watch(currentAuthUserProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  if (currentUser?.cooperativeId == null) {
    return SalesSummary(sales: [], totalRevenue: 0, totalCount: 0);
  }

  final productSales = await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    startDate: startOfMonth,
    endDate: now,
  );

  // Add milk sales
  try {
    final milkSalesRepo = ref.watch(milkSaleRepositoryProvider);
    final milkSales = await milkSalesRepo.getSalesByDateRange(currentUser.cooperativeId!, startOfMonth, now);
    
    return SalesSummary(
      sales: productSales.sales,
      totalRevenue: productSales.totalRevenue + milkSales.fold<double>(0, (sum, ms) => sum + ms.totalAmount),
      totalCount: productSales.totalCount + milkSales.length,
    );
  } catch (e) {
    return productSales;
  }
});

// Record sale state provider for form management
class RecordSaleState {
  final String? selectedProductId;
  final double? quantity;
  final double? unitPrice;
  final String? customerName;
  final String? notes;
  final bool isLoading;
  final String? error;

  RecordSaleState({
    this.selectedProductId,
    this.quantity,
    this.unitPrice,
    this.customerName,
    this.notes,
    this.isLoading = false,
    this.error,
  });

  RecordSaleState copyWith({
    String? selectedProductId,
    double? quantity,
    double? unitPrice,
    String? customerName,
    String? notes,
    bool? isLoading,
    String? error,
  }) {
    return RecordSaleState(
      selectedProductId: selectedProductId ?? this.selectedProductId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get totalAmount {
    if (quantity != null && unitPrice != null) {
      return quantity! * unitPrice!;
    }
    return 0.0;
  }
}

class RecordSaleStateNotifier extends Notifier<RecordSaleState> {
  @override
  RecordSaleState build() {
    return RecordSaleState();
  }

  void selectProduct(String productId, double defaultUnitPrice) {
    state = state.copyWith(
      selectedProductId: productId,
      unitPrice: defaultUnitPrice,
      error: null,
    );
  }

  void setQuantity(double quantity) {
    state = state.copyWith(quantity: quantity, error: null);
  }

  void setUnitPrice(double unitPrice) {
    state = state.copyWith(unitPrice: unitPrice, error: null);
  }

  void setCustomerName(String? customerName) {
    state = state.copyWith(customerName: customerName, error: null);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes, error: null);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = RecordSaleState();
  }
}

final recordSaleStateProvider =
    NotifierProvider<RecordSaleStateNotifier, RecordSaleState>(() {
  return RecordSaleStateNotifier();
});
