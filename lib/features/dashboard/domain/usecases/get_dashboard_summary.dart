import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for getting dashboard summary with today's metrics
class GetDashboardSummary {
  final MilkDeliveryRepository repository;

  GetDashboardSummary(this.repository);

  Future<Result<DashboardSummary>> call(
    String cooperativeId,
  ) async {
    // Get today's deliveries
    final result = await repository.getTodaysDeliveries(
      cooperativeId,
    );

    return result.fold(
      onError: (failure) => Error(failure),
      onSuccess: (deliveries) {
        // Calculate total liters
        final totalLiters = deliveries.fold<double>(
          0.0,
          (sum, delivery) => sum + delivery.quantityLiters,
        );

        // Count unique farmers
        final uniqueFarmerIds = deliveries.map((d) => d.farmerId).toSet();
        final farmerCount = uniqueFarmerIds.length;

        // Calculate total payment
        final totalPayment = deliveries.fold<double>(
          0.0,
          (sum, delivery) => sum + delivery.totalAmount,
        );

        final summary = DashboardSummary(
          totalLiters: totalLiters,
          farmerCount: farmerCount,
          totalPayment: totalPayment,
          date: DateTime.now(),
        );

        return Success(summary);
      },
    );
  }
}
