import 'package:livestock/features/milk_inventory/domain/repositories/milk_inventory_repository.dart';
import 'package:livestock/features/milk_sales/data/datasources/milk_sale_remote_datasource.dart';
import 'package:livestock/features/milk_sales/data/models/milk_sale_model.dart';
import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';
import 'package:livestock/features/milk_sales/domain/repositories/milk_sale_repository.dart';

/// Implementation of milk sale repository
class MilkSaleRepositoryImpl implements MilkSaleRepository {
  final MilkSaleRemoteDataSource _remoteDataSource;
  final MilkInventoryRepository _inventoryRepository;

  MilkSaleRepositoryImpl({
    required MilkSaleRemoteDataSource remoteDataSource,
    required MilkInventoryRepository inventoryRepository,
  })  : _remoteDataSource = remoteDataSource,
        _inventoryRepository = inventoryRepository;

  @override
  Future<MilkSale> recordSale(MilkSale sale) async {
    // Validate inventory availability
    final availableQuantity = await _inventoryRepository.getTotalAvailableQuantity(
      sale.cooperativeId,
    );

    if (availableQuantity < sale.quantityLiters) {
      throw Exception(
        'Insufficient inventory. Available: ${availableQuantity.toStringAsFixed(1)}L, '
        'Requested: ${sale.quantityLiters.toStringAsFixed(1)}L',
      );
    }

    // Record the sale
    final model = MilkSaleModel.fromEntity(sale);
    final result = await _remoteDataSource.recordSale(model);
    
    // Note: Inventory deduction happens automatically since we filter by isPaid
    // Sales don't directly update inventory - payment batches do
    
    return result.toEntity();
  }

  @override
  Future<List<MilkSale>> getSalesByCooperative(String cooperativeId) async {
    final models = await _remoteDataSource.getSalesByCooperative(cooperativeId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MilkSale>> getSalesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _remoteDataSource.getSalesByDateRange(
      cooperativeId,
      startDate,
      endDate,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MilkSale?> getSaleById(String saleId) async {
    // Note: We need cooperativeId, but for now we'll handle this in the use case
    throw UnimplementedError('Use getSaleByIdAndCooperative instead');
  }

  /// Get sale by ID and cooperative ID
  Future<MilkSale?> getSaleByIdAndCooperative(
    String cooperativeId,
    String saleId,
  ) async {
    final model = await _remoteDataSource.getSaleById(cooperativeId, saleId);
    return model?.toEntity();
  }

  @override
  Future<List<MilkSale>> getSalesByOffTaker(String offTakerId) async {
    // Note: We need cooperativeId, but for now we'll handle this in the use case
    throw UnimplementedError('Use getSalesByOffTakerAndCooperative instead');
  }

  /// Get sales by off-taker and cooperative ID
  Future<List<MilkSale>> getSalesByOffTakerAndCooperative(
    String cooperativeId,
    String offTakerId,
  ) async {
    final models = await _remoteDataSource.getSalesByOffTaker(
      cooperativeId,
      offTakerId,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
