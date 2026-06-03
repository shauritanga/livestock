import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/data/datasources/milk_delivery_remote_datasource.dart';
import 'package:livestock/features/milk_collection/data/models/milk_delivery_model.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Implementation of MilkDeliveryRepository with offline support
class MilkDeliveryRepositoryImpl implements MilkDeliveryRepository {
  final MilkDeliveryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MilkDeliveryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<MilkDelivery>> recordDelivery(MilkDelivery delivery) async {
    try {
      final deliveryModel = MilkDeliveryModel.fromEntity(delivery);
      final result = await remoteDataSource.recordDelivery(deliveryModel);
      return Success(result);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<MilkDelivery>> getDeliveryById(String deliveryId) async {
    try {
      throw UnimplementedError(
        'getDeliveryById requires cooperativeId, collectionCentreId, and farmerId context',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<MilkDelivery>>> getDeliveryHistory(
    String farmerId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final deliveries = await remoteDataSource.getDeliveryHistory(
        farmerId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      return Success(deliveries.cast<MilkDelivery>());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  @Deprecated('Collection centres have been removed. Use getDeliveriesByCooperative instead.')
  Future<Result<List<MilkDelivery>>> getDeliveriesByCollectionCentre(
    String cooperativeId,
    String collectionCentreId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return Error(ServerFailure(
      'getDeliveriesByCollectionCentre is deprecated. Collection centres have been removed from the data structure.',
    ));
  }

  @override
  Future<Result<List<MilkDelivery>>> getDeliveriesByCooperative(
    String cooperativeId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final now = DateTime.now();
      final effectiveStartDate = startDate ?? now.subtract(const Duration(days: 90));
      final effectiveEndDate = endDate ?? now;

      final deliveries = await remoteDataSource.getDeliveriesByCooperative(
        cooperativeId,
        effectiveStartDate,
        effectiveEndDate,
        limit: limit,
      );
      return Success(deliveries.cast<MilkDelivery>());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<MilkDelivery>>> getTodaysDeliveries(
    String cooperativeId,
  ) async {
    try {
      final deliveries = await remoteDataSource.getTodaysDeliveries(
        cooperativeId,
      );
      return Success(deliveries.cast<MilkDelivery>());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  @Deprecated('Collection centres have been removed. Use getDeliveriesByCooperative instead.')
  Future<Result<List<MilkDelivery>>> getDeliveriesByDateRange(
    String collectionCentreId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return Error(ServerFailure(
      'getDeliveriesByDateRange is deprecated. Collection centres have been removed from the data structure.',
    ));
  }

  @override
  Future<Result<double>> calculatePayment(
    double quantity,
    String qualityGrade,
    String cooperativeId,
  ) async {
    try {
      final payment = await remoteDataSource.calculatePayment(
        quantity,
        qualityGrade,
        cooperativeId,
      );
      return Success(payment);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Result<List<MilkDelivery>>> streamDeliveries(String cooperativeId) async* {
    try {
      await for (final deliveries in remoteDataSource.streamDeliveriesByCooperative(cooperativeId)) {
        yield Success(deliveries);
      }
    } on ServerException catch (e) {
      yield Error(ServerFailure(e.message));
    } catch (e) {
      yield Error(ServerFailure('Unexpected error: $e'));
    }
  }
}
