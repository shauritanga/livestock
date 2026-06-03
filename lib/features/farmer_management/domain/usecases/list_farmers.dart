import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';

/// Use case for listing farmers
class ListFarmers {
  final FarmerRepository repository;

  ListFarmers(this.repository);

  Future<Result<List<Farmer>>> call(
    String cooperativeId, {
    String? searchQuery,
    int? limit,
  }) async {
    return await repository.getFarmersByCooperative(
      cooperativeId,
      searchQuery: searchQuery,
      limit: limit,
    );
  }

  // Deprecated: Use call() instead
  @Deprecated('Use call() instead. Collection centres have been removed.')
  Future<Result<List<Farmer>>> callByCollectionCentre(
    String collectionCentreId, {
    String? searchQuery,
    int? limit,
  }) async {
    // Redirect to cooperative-level query
    // This assumes collectionCentreId was actually a cooperativeId
    return await repository.getFarmersByCooperative(
      collectionCentreId,
      searchQuery: searchQuery,
      limit: limit,
    );
  }

  Future<Result<List<Farmer>>> callByCooperative(
    String cooperativeId, {
    String? searchQuery,
    int? limit,
  }) async {
    return await repository.getFarmersByCooperative(
      cooperativeId,
      searchQuery: searchQuery,
      limit: limit,
    );
  }
}
