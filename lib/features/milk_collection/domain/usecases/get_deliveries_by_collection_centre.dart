import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for getting all deliveries for a cooperative
/// @deprecated Collection centres have been removed. Use cooperative-level queries instead.
@Deprecated('Collection centres have been removed. This class will be removed in a future version.')
class GetDeliveriesByCollectionCentre {
  final MilkDeliveryRepository repository;

  GetDeliveriesByCollectionCentre(this.repository);

  Future<Result<List<MilkDelivery>>> call(
    String cooperativeId,
    String collectionCentreId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Redirect to cooperative-level query (collectionCentreId is ignored)
    return await repository.getDeliveriesByCooperative(
      cooperativeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
