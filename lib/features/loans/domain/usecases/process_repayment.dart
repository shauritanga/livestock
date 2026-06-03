import '../../../../core/utils/result.dart';
import '../entities/loan_repayment.dart';
import '../repositories/loan_repository.dart';

/// Use case for processing loan repayment
class ProcessRepayment {
  final LoanRepository repository;

  ProcessRepayment(this.repository);

  Future<Result<LoanRepayment>> call({
    required String loanId,
    required double amount,
    required double principalPaid,
    required double interestPaid,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  }) {
    return repository.processRepayment(
      loanId: loanId,
      amount: amount,
      principalPaid: principalPaid,
      interestPaid: interestPaid,
      paymentMethod: paymentMethod,
      milkDeliveryId: milkDeliveryId,
    );
  }
}
