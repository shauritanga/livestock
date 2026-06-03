import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/data/datasources/farmer_remote_datasource.dart';
import 'package:livestock/features/farmer_management/data/models/farmer_model.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';

/// Implementation of FarmerRepository with offline support
class FarmerRepositoryImpl implements FarmerRepository {
  final FarmerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FarmerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Farmer>> registerFarmer(Farmer farmer) async {
    try {
      final farmerModel = FarmerModel.fromEntity(farmer);
      final result = await remoteDataSource.registerFarmer(farmerModel);
      return Success(result);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Farmer>> getFarmerById(String farmerId) async {
    try {
      final farmer = await remoteDataSource.getFarmerById(farmerId);
      return Success(farmer);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Farmer>> updateFarmer(Farmer farmer) async {
    try {
      final farmerModel = FarmerModel.fromEntity(farmer);
      final result = await remoteDataSource.updateFarmer(farmerModel);
      return Success(result);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  @Deprecated('Collection centres have been removed. Use getFarmersByCooperative instead.')
  Future<Result<List<Farmer>>> getFarmersByCollectionCentre(
    String collectionCentreId, {
    String? searchQuery,
    int? limit,
  }) async {
    return Error(ServerFailure(
      'getFarmersByCollectionCentre is deprecated. Collection centres have been removed from the data structure.',
    ));
  }

  @override
  Future<Result<List<Farmer>>> getFarmersByCooperative(
    String cooperativeId, {
    String? searchQuery,
    int? limit,
  }) async {
    try {
      final farmers = await remoteDataSource.getFarmersByCooperative(
        cooperativeId,
        searchQuery: searchQuery,
        limit: limit,
      );
      return Success(farmers);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteFarmer(String farmerId) async {
    try {
      await remoteDataSource.deleteFarmer(farmerId);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateCattleCounts(
    String farmerId,
    int totalCattle,
    int lactatingCattle,
  ) async {
    try {
      await remoteDataSource.updateCattleCounts(
        farmerId,
        totalCattle,
        lactatingCattle,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateLastDeliveryDate(
    String farmerId,
    DateTime deliveryDate,
  ) async {
    try {
      await remoteDataSource.updateLastDeliveryDate(farmerId, deliveryDate);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }
}
