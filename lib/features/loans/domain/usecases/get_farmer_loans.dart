import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

/// Use case for getting all loans for a farmer
class GetFarmerLoans {
  final LoanRepository repository;

  GetFarmerLoans(this.repository);

  Future<Result<List<Loan>>> call(String farmerId) {
    return repository.getFarmerLoans(farmerId);
  }
}
