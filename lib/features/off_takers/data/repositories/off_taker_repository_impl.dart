import 'package:livestock/core/utils/result.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/repositories/off_taker_repository.dart';
import 'package:livestock/features/off_takers/data/datasources/off_taker_remote_datasource.dart';
import 'package:livestock/features/off_takers/data/models/off_taker_model.dart';

/// Implementation of OffTakerRepository (MVP)
class OffTakerRepositoryImpl implements OffTakerRepository {
  final OffTakerRemoteDataSource remoteDataSource;
  final String cooperativeId;

  OffTakerRepositoryImpl({
    required this.remoteDataSource,
    required this.cooperativeId,
  });

  @override
  Future<Result<OffTaker>> createOffTaker(OffTaker offTaker) async {
    try {
      final model = OffTakerModel.fromEntity(offTaker);
      final createdModel = await remoteDataSource.createOffTaker(model);
      return Success(createdModel.toEntity());
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OffTaker>>> getAllOffTakers({
    OffTakerCategory? category,
  }) async {
    try {
      final models = await remoteDataSource.getAllOffTakers(
        cooperativeId,
        category: category,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<OffTaker?>> getOffTakerById(String id) async {
    try {
      final model = await remoteDataSource.getOffTakerById(id);
      if (model == null) {
        return const Success(null);
      }
      return Success(model.toEntity());
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
