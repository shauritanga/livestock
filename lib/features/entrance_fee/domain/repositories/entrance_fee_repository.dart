import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';
import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';
import 'package:livestock/features/entrance_fee/domain/entities/payment_summary.dart';

/// Abstract repository interface for entrance fee operations
abstract class EntranceFeeRepository {
  /// Record a new entrance fee payment
  Future<EntranceFee> recordPayment(EntranceFee fee);

  /// Get payment record for a specific farmer
  Future<EntranceFee?> getPaymentByFarmerId(String farmerId);

  /// Get payment status for all farmers in a cooperative
  Stream<List<FarmerPaymentStatus>> getAllFarmersPaymentStatus(
    String cooperativeId,
  );

  /// Get summary statistics for entrance fee payments
  Future<PaymentSummary> getPaymentSummary(String cooperativeId);
}
