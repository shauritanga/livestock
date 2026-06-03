import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for recording a milk delivery
class RecordDelivery {
  final MilkDeliveryRepository repository;

  RecordDelivery(this.repository);

  Future<Result<MilkDelivery>> call(MilkDelivery delivery) async {
    return await repository.recordDelivery(delivery);
  }
}
