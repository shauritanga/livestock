import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/data/datasources/cattle_remote_datasource.dart';
import 'package:livestock/features/cattle_tracking/data/models/cattle_model.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';

/// Implementation of CattleRepository with offline support
class CattleRepositoryImpl implements CattleRepository {
  final CattleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CattleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Cattle>> registerCattle(Cattle cattle) async {
    try {
      final cattleModel = CattleModel.fromEntity(cattle);
      final result = await remoteDataSource.registerCattle(cattleModel);
      return Success(result);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Cattle>> getCattleById(String cattleId) async {
    try {
      // Note: In a real implementation, we would need cooperativeId, collectionCentreId, and farmerId
      throw UnimplementedError(
        'getCattleById requires cooperativeId, collectionCentreId, and farmerId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Cattle>> updateCattle(Cattle cattle) async {
    try {
      final cattleModel = CattleModel.fromEntity(cattle);
      final result = await remoteDataSource.updateCattle(cattleModel);
      return Success(result);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Cattle>>> getCattleByFarmer(String farmerId) async {
    try {
      // Note: In a real implementation, we would need cooperativeId and collectionCentreId
      throw UnimplementedError(
        'getCattleByFarmer requires cooperativeId and collectionCentreId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Cattle>>> getCattleByCollectionCentre(
    String collectionCentreId,
  ) async {
    try {
      // Note: In a real implementation, we would need cooperativeId
      throw UnimplementedError(
        'getCattleByCollectionCentre requires cooperativeId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Cattle>>> getCattleByCooperative(
    String cooperativeId,
  ) async {
    try {
      final cattle =
          await remoteDataSource.getCattleByCooperative(cooperativeId);
      return Success(cattle);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCattle(String cattleId) async {
    try {
      // Note: In a real implementation, we would need cooperativeId, collectionCentreId, and farmerId
      throw UnimplementedError(
        'deleteCattle requires cooperativeId, collectionCentreId, and farmerId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Map<String, int>>> getHerdComposition(String farmerId) async {
    try {
      // Note: In a real implementation, we would need cooperativeId and collectionCentreId
      throw UnimplementedError(
        'getHerdComposition requires cooperativeId and collectionCentreId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }
}
