import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

/// Use case for getting loan details by ID
class GetLoanDetails {
  final LoanRepository repository;

  GetLoanDetails(this.repository);

  Future<Result<Loan>> call(String loanId) {
    return repository.getLoanById(loanId);
  }
}
