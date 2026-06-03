import 'package:equatable/equatable.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';

/// Inventory batch representing milk from a specific delivery
class InventoryBatch extends Equatable {
  final String deliveryId;
  final String farmerId;
  final String farmerName;
  final double quantity;
  final MilkQualityGrade grade;
  final DateTime collectionDate;

  const InventoryBatch({
    required this.deliveryId,
    required this.farmerId,
    required this.farmerName,
    required this.quantity,
    required this.grade,
    required this.collectionDate,
  });

  /// Get age of this batch in hours
  int get ageInHours {
    return DateTime.now().difference(collectionDate).inHours;
  }

  /// Check if batch is aging (older than 48 hours)
  bool get isAging => ageInHours > 48;

  /// Check if batch is fresh (less than 24 hours)
  bool get isFresh => ageInHours < 24;

  @override
  List<Object?> get props => [
        deliveryId,
        farmerId,
        farmerName,
        quantity,
        grade,
        collectionDate,
      ];
}
