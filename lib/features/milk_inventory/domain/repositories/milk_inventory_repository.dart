import 'package:livestock/features/milk_inventory/domain/entities/inventory_batch.dart';
import 'package:livestock/features/milk_inventory/domain/entities/milk_inventory.dart';

/// Abstract repository interface for milk inventory operations
abstract class MilkInventoryRepository {
  /// Get current milk inventory for a cooperative
  Stream<MilkInventory> getInventory(String cooperativeId);

  /// Get total available quantity
  Future<double> getTotalAvailableQuantity(String cooperativeId);

  /// Get inventory batches sorted by collection date
  Future<List<InventoryBatch>> getInventoryBatches(String cooperativeId);
}
