import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

/// Use case for applying for a loan
class ApplyForLoan {
  final LoanRepository repository;

  ApplyForLoan(this.repository);

  Future<Result<Loan>> call({
    required String farmerId,
    required String cooperativeId,
    required double principalAmount,
    required double interestRate,
    required int termMonths,
    required String mfiPartnerId,
  }) {
    return repository.applyForLoan(
      farmerId: farmerId,
      cooperativeId: cooperativeId,
      principalAmount: principalAmount,
      interestRate: interestRate,
      termMonths: termMonths,
      mfiPartnerId: mfiPartnerId,
    );
  }
}
