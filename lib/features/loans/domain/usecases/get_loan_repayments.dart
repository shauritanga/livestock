import '../../../../core/utils/result.dart';
import '../entities/loan_repayment.dart';
import '../repositories/loan_repository.dart';

/// Use case for getting loan repayment history
class GetLoanRepayments {
  final LoanRepository repository;

  GetLoanRepayments(this.repository);

  Future<Result<List<LoanRepayment>>> call(String loanId) {
    return repository.getLoanRepayments(loanId);
  }
}
