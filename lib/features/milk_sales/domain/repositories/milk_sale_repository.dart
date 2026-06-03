import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';

/// Abstract repository interface for milk sale operations
abstract class MilkSaleRepository {
  /// Record a new milk sale
  Future<MilkSale> recordSale(MilkSale sale);

  /// Get all sales for a cooperative
  Future<List<MilkSale>> getSalesByCooperative(String cooperativeId);

  /// Get sales filtered by date range
  Future<List<MilkSale>> getSalesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get sale by ID
  Future<MilkSale?> getSaleById(String saleId);

  /// Get sales by off-taker
  Future<List<MilkSale>> getSalesByOffTaker(String offTakerId);
}
