import 'package:equatable/equatable.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_inventory/domain/entities/inventory_batch.dart';

/// Milk inventory entity representing available milk for sale
class MilkInventory extends Equatable {
  final String cooperativeId;
  final double totalQuantity;
  final Map<MilkQualityGrade, double> quantityByGrade;
  final List<InventoryBatch> batches;
  final DateTime lastUpdated;

  const MilkInventory({
    required this.cooperativeId,
    required this.totalQuantity,
    required this.quantityByGrade,
    required this.batches,
    required this.lastUpdated,
  });

  /// Check if inventory is empty
  bool get isEmpty => totalQuantity <= 0;

  /// Get quantity for a specific grade
  double getQuantityForGrade(MilkQualityGrade grade) {
    return quantityByGrade[grade] ?? 0.0;
  }

  /// Get oldest batch
  InventoryBatch? get oldestBatch {
    if (batches.isEmpty) return null;
    return batches.reduce((a, b) => 
      a.collectionDate.isBefore(b.collectionDate) ? a : b
    );
  }

  /// Get batches older than specified hours
  List<InventoryBatch> getBatchesOlderThan(int hours) {
    final cutoffDate = DateTime.now().subtract(Duration(hours: hours));
    return batches.where((batch) => 
      batch.collectionDate.isBefore(cutoffDate)
    ).toList();
  }

  @override
  List<Object?> get props => [
        cooperativeId,
        totalQuantity,
        quantityByGrade,
        batches,
        lastUpdated,
      ];
}
