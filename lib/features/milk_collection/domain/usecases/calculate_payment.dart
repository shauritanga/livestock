import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for calculating payment
class CalculatePayment {
  final MilkDeliveryRepository repository;

  CalculatePayment(this.repository);

  Future<Result<double>> call(
    double quantity,
    String qualityGrade,
    String cooperativeId,
  ) async {
    return await repository.calculatePayment(
      quantity,
      qualityGrade,
      cooperativeId,
    );
  }
}
