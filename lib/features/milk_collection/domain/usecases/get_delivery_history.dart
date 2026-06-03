import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for getting delivery history
class GetDeliveryHistory {
  final MilkDeliveryRepository repository;

  GetDeliveryHistory(this.repository);

  Future<Result<List<MilkDelivery>>> call(
    String farmerId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return await repository.getDeliveryHistory(
      farmerId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}
