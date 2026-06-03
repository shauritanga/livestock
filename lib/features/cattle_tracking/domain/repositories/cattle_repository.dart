import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';

/// Repository interface for cattle data operations
abstract class CattleRepository {
  /// Register a new cattle
  Future<Result<Cattle>> registerCattle(Cattle cattle);

  /// Get cattle details by ID
  Future<Result<Cattle>> getCattleById(String cattleId);

  /// Update cattle information
  Future<Result<Cattle>> updateCattle(Cattle cattle);

  /// Get list of cattle for a farmer
  Future<Result<List<Cattle>>> getCattleByFarmer(String farmerId);

  /// Get list of cattle for a collection centre
  Future<Result<List<Cattle>>> getCattleByCollectionCentre(
    String collectionCentreId,
  );

  /// Get list of cattle for a cooperative
  Future<Result<List<Cattle>>> getCattleByCooperative(String cooperativeId);

  /// Delete a cattle
  Future<Result<void>> deleteCattle(String cattleId);

  /// Get herd composition statistics for a farmer
  Future<Result<Map<String, int>>> getHerdComposition(String farmerId);
}
