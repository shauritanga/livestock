import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for getting today's deliveries
class GetTodaysDeliveries {
  final MilkDeliveryRepository repository;

  GetTodaysDeliveries(this.repository);

  Future<Result<List<MilkDelivery>>> call(
    String cooperativeId,
  ) async {
    return await repository.getTodaysDeliveries(
      cooperativeId,
    );
  }
}
