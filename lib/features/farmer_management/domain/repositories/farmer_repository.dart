import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';

/// Repository interface for farmer data operations
abstract class FarmerRepository {
  /// Register a new farmer
  Future<Result<Farmer>> registerFarmer(Farmer farmer);

  /// Get farmer details by ID
  Future<Result<Farmer>> getFarmerById(String farmerId);

  /// Update farmer information
  Future<Result<Farmer>> updateFarmer(Farmer farmer);

  /// Get list of farmers for a collection centre
  Future<Result<List<Farmer>>> getFarmersByCollectionCentre(
    String collectionCentreId, {
    String? searchQuery,
    int? limit,
  });

  /// Get list of farmers for a cooperative
  Future<Result<List<Farmer>>> getFarmersByCooperative(
    String cooperativeId, {
    String? searchQuery,
    int? limit,
  });

  /// Delete a farmer
  Future<Result<void>> deleteFarmer(String farmerId);

  /// Update farmer cattle counts
  Future<Result<void>> updateCattleCounts(
    String farmerId,
    int totalCattle,
    int lactatingCattle,
  );

  /// Update farmer's last delivery date
  Future<Result<void>> updateLastDeliveryDate(
    String farmerId,
    DateTime deliveryDate,
  );
}
