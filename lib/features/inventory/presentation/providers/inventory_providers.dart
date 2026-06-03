import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:livestock/core/database/database_helper.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:livestock/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:livestock/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/get_all_products.dart';
import 'package:livestock/features/inventory/domain/usecases/get_product_by_id.dart';
import 'package:livestock/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:livestock/features/inventory/domain/usecases/search_products.dart';
import 'package:livestock/features/inventory/domain/usecases/register_product.dart';
import 'package:livestock/features/inventory/domain/usecases/update_product.dart';
import 'package:livestock/features/milk_inventory/presentation/providers/milk_inventory_providers.dart';

// Database provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseHelper.database;
});

// Data source providers
final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final inventoryLocalDataSourceProvider = FutureProvider<InventoryLocalDataSource>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return InventoryLocalDataSource(database);
});

// Repository provider
final inventoryRepositoryProvider = FutureProvider<InventoryRepository>((ref) async {
  final remoteDataSource = ref.watch(inventoryRemoteDataSourceProvider);
  final localDataSource = await ref.watch(inventoryLocalDataSourceProvider.future);
  return InventoryRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Use case providers
final registerProductUseCaseProvider = FutureProvider<RegisterProduct>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return RegisterProduct(repository);
});

final updateProductUseCaseProvider = FutureProvider<UpdateProduct>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return UpdateProduct(repository);
});

final getAllProductsUseCaseProvider = FutureProvider<GetAllProducts>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetAllProducts(repository);
});

final getProductByIdUseCaseProvider = FutureProvider<GetProductById>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetProductById(repository);
});

final getLowStockProductsUseCaseProvider = FutureProvider<GetLowStockProducts>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetLowStockProducts(repository);
});

final searchProductsUseCaseProvider = FutureProvider<SearchProducts>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return SearchProducts(repository);
});

// Enum for stock status filtering
enum StockStatusFilter {
  all,
  inStock,
  lowStock,
  outOfStock,
}

// State notifiers for filtering
class SelectedCategoryNotifier extends Notifier<ProductCategory?> {
  @override
  ProductCategory? build() => null;

  void setCategory(ProductCategory? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

class StockStatusFilterNotifier extends Notifier<StockStatusFilter> {
  @override
  StockStatusFilter build() => StockStatusFilter.all;

  void setFilter(StockStatusFilter filter) {
    state = filter;
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, ProductCategory?>(() {
  return SelectedCategoryNotifier();
});

final stockStatusFilterProvider = NotifierProvider<StockStatusFilterNotifier, StockStatusFilter>(() {
  return StockStatusFilterNotifier();
});

// Products provider with filtering (includes milk from milk inventory)
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = await ref.watch(getAllProductsUseCaseProvider.future);
  final category = ref.watch(selectedCategoryProvider);
  final stockFilter = ref.watch(stockStatusFilterProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return [];
  }

  bool? isLowStock;
  bool? isOutOfStock;

  switch (stockFilter) {
    case StockStatusFilter.lowStock:
      isLowStock = true;
      break;
    case StockStatusFilter.outOfStock:
      isOutOfStock = true;
      break;
    case StockStatusFilter.inStock:
    case StockStatusFilter.all:
      break;
  }

  // Get regular products
  final regularProducts = await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    category: category,
    isLowStock: isLowStock,
    isOutOfStock: isOutOfStock,
    activeOnly: true,
  );

  // Get milk inventory and add as virtual product
  try {
    final milkInventoryRepository = ref.watch(milkInventoryRepositoryProvider);
    final milkQuantity = await milkInventoryRepository.getTotalAvailableQuantity(currentUser.cooperativeId!);
    
    // Create virtual milk product
    final milkProduct = Product(
      id: 'MILK-VIRTUAL',
      cooperativeId: currentUser.cooperativeId!,
      sku: 'MILK-001',
      name: 'Fresh Milk',
      category: ProductCategory.other,
      unitOfMeasure: 'Liters',
      unitPrice: 1500.0, // Default price per liter
      currentStock: milkQuantity,
      reorderPoint: 50.0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
    );
    
    // Apply filters to milk product
    bool includeMilk = true;
    if (category != null && category != ProductCategory.other) {
      includeMilk = false;
    }
    if (isLowStock == true && !milkProduct.isLowStock) {
      includeMilk = false;
    }
    if (isOutOfStock == true && !milkProduct.isOutOfStock) {
      includeMilk = false;
    }
    
    // Combine products
    if (includeMilk) {
      return [milkProduct, ...regularProducts];
    }
  } catch (e) {
    // If milk inventory fails, just return regular products
  }

  return regularProducts;
});

// Product by ID provider
final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final useCase = await ref.watch(getProductByIdUseCaseProvider.future);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return null;
  }

  return await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    id: id,
  );
});

// Low stock products provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = await ref.watch(getLowStockProductsUseCaseProvider.future);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return [];
  }

  return await useCase(cooperativeId: currentUser!.cooperativeId!);
});

// Low stock count provider
final lowStockCountProvider = FutureProvider<int>((ref) async {
  final products = await ref.watch(lowStockProductsProvider.future);
  return products.length;
});

// Search query notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final productSearchProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final currentUser = ref.watch(currentAuthUserProvider);
  
  if (query.trim().isEmpty || currentUser?.cooperativeId == null) {
    return [];
  }

  final useCase = await ref.watch(searchProductsUseCaseProvider.future);
  
  // Add a small delay for debouncing
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Check if query changed during delay
  if (query != ref.read(searchQueryProvider)) {
    return [];
  }

  return await useCase(
    cooperativeId: currentUser!.cooperativeId!,
    query: query,
  );
});
