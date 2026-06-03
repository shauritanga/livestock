import 'package:livestock/features/payment_batch/domain/entities/farmer_payment_summary.dart';
import 'package:livestock/features/payment_batch/domain/entities/payment_batch.dart';

/// Abstract repository interface for payment batch operations
abstract class PaymentBatchRepository {
  /// Create a new payment batch
  Future<PaymentBatch> createPaymentBatch(
    String cooperativeId,
    DateTime periodStart,
    DateTime periodEnd,
    String createdBy,
  );

  /// Generate payment summaries for a period
  Future<List<FarmerPaymentSummary>> generatePaymentSummaries(
    String cooperativeId,
    DateTime periodStart,
    DateTime periodEnd,
    double pricePerLiter,
  );

  /// Process a payment batch
  Future<void> processPaymentBatch(
    String batchId,
    DateTime processedDate,
    String paymentMethod,
    String? batchReference,
  );

  /// Get all payment batches for a cooperative
  Future<List<PaymentBatch>> getPaymentBatches(String cooperativeId);

  /// Get payment batch by ID
  Future<PaymentBatch?> getPaymentBatchById(String batchId);

  /// Get payment summaries for a batch
  Future<List<FarmerPaymentSummary>> getPaymentSummariesForBatch(String batchId);
}
