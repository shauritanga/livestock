import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

/// Use case for approving a loan
class ApproveLoan {
  final LoanRepository repository;

  ApproveLoan(this.repository);

  Future<Result<Loan>> call(String loanId) {
    return repository.approveLoan(loanId);
  }
}
