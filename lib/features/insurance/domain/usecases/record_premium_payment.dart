import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for recording a premium payment
/// 
/// This use case handles manual premium payment recording by collection agents.
/// Automatic deductions from milk payments are handled by Cloud Functions.
/// 
/// Requirements: 2.3, 2.4, 2.8
class RecordPremiumPaymentUseCase {
  final InsuranceRepository repository;

  RecordPremiumPaymentUseCase(this.repository);

  /// Records a premium payment
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// - [amount]: The payment amount
  /// - [paymentMethod]: How the payment was made (cash or mobile money)
  /// - [milkDeliveryId]: Optional ID if payment was from milk deduction
  /// 
  /// Returns:
  /// - Success with void on successful recording
  /// - Error with ValidationFailure if amount is invalid
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if recording fails
  Future<Result<void>> call({
    required String policyId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  }) async {
    // Validate payment amount
    if (amount <= 0) {
      return const Error(
        ValidationFailure('Payment amount must be greater than zero'),
      );
    }

    // Record the payment
    return await repository.recordPremiumPayment(
      policyId: policyId,
      amount: amount,
      paymentMethod: paymentMethod,
      milkDeliveryId: milkDeliveryId,
    );
  }
}
