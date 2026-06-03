import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';

/// Repository interface for milk delivery data operations
abstract class MilkDeliveryRepository {
  /// Record a new milk delivery
  Future<Result<MilkDelivery>> recordDelivery(MilkDelivery delivery);

  /// Get delivery by ID
  Future<Result<MilkDelivery>> getDeliveryById(String deliveryId);

  /// Get delivery history for a farmer
  Future<Result<List<MilkDelivery>>> getDeliveryHistory(
    String farmerId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get deliveries for a collection centre
  Future<Result<List<MilkDelivery>>> getDeliveriesByCollectionCentre(
    String cooperativeId,
    String collectionCentreId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get deliveries for a cooperative
  Future<Result<List<MilkDelivery>>> getDeliveriesByCooperative(
    String cooperativeId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get today's deliveries for a cooperative
  Future<Result<List<MilkDelivery>>> getTodaysDeliveries(
    String cooperativeId,
  );

  /// Get deliveries by date range for a collection centre
  Future<Result<List<MilkDelivery>>> getDeliveriesByDateRange(
    String collectionCentreId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate payment for a delivery
  Future<Result<double>> calculatePayment(
    double quantity,
    String qualityGrade,
    String cooperativeId,
  );

  /// Stream deliveries for a cooperative (for real-time inventory)
  Stream<Result<List<MilkDelivery>>> streamDeliveries(String cooperativeId);
}
