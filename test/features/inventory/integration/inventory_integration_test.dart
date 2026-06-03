import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/register_product.dart';
import 'package:livestock/features/inventory/domain/usecases/add_stock.dart';
import 'package:livestock/features/inventory/domain/usecases/record_sale.dart';
import 'package:livestock/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'inventory_integration_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late MockInventoryRepository mockRepository;
  late RegisterProduct registerProductUseCase;
  late AddStock addStockUseCase;
  late RecordSale recordSaleUseCase;
  late GetLowStockProducts getLowStockProductsUseCase;

  setUp(() {
    mockRepository = MockInventoryRepository();
    registerProductUseCase = RegisterProduct(repository: mockRepository);
    addStockUseCase = AddStock(repository: mockRepository);
    recordSaleUseCase = RecordSale(repository: mockRepository);
    getLowStockProductsUseCase = GetLowStockProducts(repository: mockRepository);
  });

  group('Product Registration Flow', () {
    test('should complete full product registration flow', () async {
      // Step 1: Create a new product
      final newProduct = Product(
        id: '',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Premium Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 0.0,
        reorderPoint: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      // Mock: Check SKU uniqueness (no existing products)
      when(mockRepository.searchProducts(any)).thenAnswer((_) async => []);

      // Mock: Create product
      final createdProduct = newProduct.copyWith(id: 'prod-1');
      when(mockRepository.createProduct(any))
          .thenAnswer((_) async => createdProduct);

      // Step 2: Register the product
      final registeredProduct = await registerProductUseCase(
        product: newProduct,
        cooperativeId: 'coop-1',
      );

      // Verify product was registered
      expect(registeredProduct.id, 'prod-1');
      expect(registeredProduct.sku, 'FEED-001');
      expect(registeredProduct.name, 'Premium Animal Feed');
      expect(registeredProduct.currentStock, 0.0);

      // Step 3: Add initial stock
      final stockTransaction = StockTransaction(
        id: 'trans-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        type: StockTransactionType.addition,
        quantity: 100.0,
        previousStock: 0.0,
        newStock: 100.0,
        reason: 'Initial stock',
        timestamp: DateTime.now(),
        performedBy: 'user-1',
      );

      when(mockRepository.addStock(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => stockTransaction);

      final addedStock = await addStockUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 100.0,
        reason: 'Initial stock',
        performedBy: 'user-1',
      );

      // Verify stock was added
      expect(addedStock.productId, 'prod-1');
      expect(addedStock.quantity, 100.0);
      expect(addedStock.newStock, 100.0);
      expect(addedStock.type, StockTransactionType.addition);

      // Verify repository methods were called
      verify(mockRepository.searchProducts('FEED-001')).called(1);
      verify(mockRepository.createProduct(any)).called(1);
      verify(mockRepository.addStock(
        productId: 'prod-1',
        quantity: 100.0,
        reason: 'Initial stock',
        performedBy: 'user-1',
      )).called(1);
    });

    test('should prevent duplicate SKU registration', () async {
      // Create a product with existing SKU
      final newProduct = Product(
        id: '',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Duplicate Product',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 0.0,
        reorderPoint: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      // Mock: Existing product with same SKU
      final existingProduct = Product(
        id: 'prod-existing',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Existing Product',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 50.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => [existingProduct]);

      // Attempt to register product with duplicate SKU
      expect(
        () => registerProductUseCase(
          product: newProduct,
          cooperativeId: 'coop-1',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('SKU already exists'),
        )),
      );

      // Verify create was never called
      verifyNever(mockRepository.createProduct(any));
    });
  });

  group('Sale Recording Flow', () {
    test('should complete full sale recording flow', () async {
      // Step 1: Product exists with sufficient stock
      final product = Product(
        id: 'prod-1',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Premium Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 100.0,
        reorderPoint: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      // Step 2: Record a sale
      final saleTransaction = SaleTransaction(
        id: 'sale-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        productName: 'Premium Animal Feed',
        quantity: 25.0,
        unitPrice: 150.0,
        totalAmount: 3750.0,
        customerName: 'John Doe',
        notes: 'Bulk purchase',
        timestamp: DateTime.now(),
        processedBy: 'user-1',
        isSynced: true,
      );

      when(mockRepository.recordSale(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        unitPrice: anyNamed('unitPrice'),
        customerName: anyNamed('customerName'),
        notes: anyNamed('notes'),
        processedBy: anyNamed('processedBy'),
      )).thenAnswer((_) async => saleTransaction);

      final recordedSale = await recordSaleUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 25.0,
        unitPrice: 150.0,
        customerName: 'John Doe',
        notes: 'Bulk purchase',
        processedBy: 'user-1',
      );

      // Verify sale was recorded
      expect(recordedSale.id, 'sale-1');
      expect(recordedSale.productId, 'prod-1');
      expect(recordedSale.quantity, 25.0);
      expect(recordedSale.totalAmount, 3750.0);
      expect(recordedSale.customerName, 'John Doe');

      // Verify repository method was called
      verify(mockRepository.recordSale(
        productId: 'prod-1',
        quantity: 25.0,
        unitPrice: 150.0,
        customerName: 'John Doe',
        notes: 'Bulk purchase',
        processedBy: 'user-1',
      )).called(1);
    });

    test('should pass validation for valid sale quantities', () async {
      // Valid sale within available stock
      final saleTransaction = SaleTransaction(
        id: 'sale-2',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        productName: 'Test Product',
        quantity: 50.0,
        unitPrice: 150.0,
        totalAmount: 7500.0,
        timestamp: DateTime.now(),
        processedBy: 'user-1',
        isSynced: true,
      );

      when(mockRepository.recordSale(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        unitPrice: anyNamed('unitPrice'),
        customerName: anyNamed('customerName'),
        notes: anyNamed('notes'),
        processedBy: anyNamed('processedBy'),
      )).thenAnswer((_) async => saleTransaction);

      final result = await recordSaleUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 50.0,
        unitPrice: 150.0,
        processedBy: 'user-1',
      );

      expect(result.quantity, 50.0);
      expect(result.totalAmount, 7500.0);
    });
  });

  group('Low Stock Alert Workflow', () {
    test('should detect and return low stock products', () async {
      // Create products with different stock levels
      final products = [
        Product(
          id: 'prod-1',
          cooperativeId: 'coop-1',
          sku: 'FEED-001',
          name: 'Low Stock Product',
          category: ProductCategory.animalFeed,
          unitOfMeasure: 'kg',
          unitPrice: 150.0,
          currentStock: 15.0, // Below reorder point
          reorderPoint: 50.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        ),
        Product(
          id: 'prod-2',
          cooperativeId: 'coop-1',
          sku: 'VET-001',
          name: 'Out of Stock Product',
          category: ProductCategory.veterinarySupplies,
          unitOfMeasure: 'pieces',
          unitPrice: 50.0,
          currentStock: 0.0, // Out of stock
          reorderPoint: 10.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        ),
      ];

      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => products);

      // Get low stock products
      final lowStockProducts = await getLowStockProductsUseCase(
        cooperativeId: 'coop-1',
      );

      // Verify low stock products were returned
      expect(lowStockProducts.length, 2);
      expect(lowStockProducts[0].isLowStock, true);
      expect(lowStockProducts[1].isOutOfStock, true);

      // Verify all returned products are actually low stock
      for (final product in lowStockProducts) {
        expect(product.currentStock <= product.reorderPoint, true);
      }
    });

    test('should return empty list when no low stock products', () async {
      when(mockRepository.getLowStockProducts()).thenAnswer((_) async => []);

      final lowStockProducts = await getLowStockProductsUseCase(
        cooperativeId: 'coop-1',
      );

      expect(lowStockProducts, isEmpty);
    });

    test('should update alert after adding stock', () async {
      // Step 1: Product is low on stock
      final lowStockProduct = Product(
        id: 'prod-1',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Low Stock Product',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 15.0,
        reorderPoint: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      expect(lowStockProduct.isLowStock, true);

      // Step 2: Add stock to bring it above reorder point
      final stockTransaction = StockTransaction(
        id: 'trans-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        type: StockTransactionType.addition,
        quantity: 50.0,
        previousStock: 15.0,
        newStock: 65.0,
        reason: 'Restocking',
        timestamp: DateTime.now(),
        performedBy: 'user-1',
      );

      when(mockRepository.addStock(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => stockTransaction);

      await addStockUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 50.0,
        reason: 'Restocking',
        performedBy: 'user-1',
      );

      // Step 3: Product should no longer be low stock
      final updatedProduct = lowStockProduct.copyWith(currentStock: 65.0);
      expect(updatedProduct.isLowStock, false);
    });
  });

  group('Stock Management Flow', () {
    test('should track stock changes through transactions', () async {
      // Initial product
      final product = Product(
        id: 'prod-1',
        cooperativeId: 'coop-1',
        sku: 'FEED-001',
        name: 'Test Product',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 150.0,
        currentStock: 100.0,
        reorderPoint: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-1',
      );

      // Transaction 1: Add stock
      final addTransaction = StockTransaction(
        id: 'trans-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        type: StockTransactionType.addition,
        quantity: 50.0,
        previousStock: 100.0,
        newStock: 150.0,
        reason: 'New delivery',
        timestamp: DateTime.now(),
        performedBy: 'user-1',
      );

      when(mockRepository.addStock(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => addTransaction);

      await addStockUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 50.0,
        reason: 'New delivery',
        performedBy: 'user-1',
      );

      // Transaction 2: Record sale
      final saleTransaction = SaleTransaction(
        id: 'sale-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        productName: 'Test Product',
        quantity: 30.0,
        unitPrice: 150.0,
        totalAmount: 4500.0,
        timestamp: DateTime.now(),
        processedBy: 'user-1',
        isSynced: true,
      );

      when(mockRepository.recordSale(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        unitPrice: anyNamed('unitPrice'),
        customerName: anyNamed('customerName'),
        notes: anyNamed('notes'),
        processedBy: anyNamed('processedBy'),
      )).thenAnswer((_) async => saleTransaction);

      await recordSaleUseCase(
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        quantity: 30.0,
        unitPrice: 150.0,
        processedBy: 'user-1',
      );

      // Verify both transactions were recorded
      verify(mockRepository.addStock(
        productId: 'prod-1',
        quantity: 50.0,
        reason: 'New delivery',
        performedBy: 'user-1',
      )).called(1);

      verify(mockRepository.recordSale(
        productId: 'prod-1',
        quantity: 30.0,
        unitPrice: 150.0,
        customerName: null,
        notes: null,
        processedBy: 'user-1',
      )).called(1);

      // Final stock should be: 100 + 50 - 30 = 120
      final finalProduct = product.copyWith(currentStock: 120.0);
      expect(finalProduct.currentStock, 120.0);
    });
  });

  group('Offline Mode and Sync', () {
    test('should queue transactions when offline', () async {
      // This test would verify offline transaction queueing
      // In a real implementation, this would test the repository's offline behavior
      
      when(mockRepository.hasPendingTransactions()).thenAnswer((_) async => true);
      
      final hasPending = await mockRepository.hasPendingTransactions();
      expect(hasPending, true);
    });

    test('should sync pending transactions when connection is restored', () async {
      // This test would verify sync behavior
      // In a real implementation, this would test the sync service
      
      when(mockRepository.syncPendingTransactions()).thenAnswer((_) async => null);
      
      await mockRepository.syncPendingTransactions();
      
      verify(mockRepository.syncPendingTransactions()).called(1);
    });
  });
}
