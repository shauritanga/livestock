import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../entities/loan_repayment.dart';

/// Repository interface for loan operations
abstract class LoanRepository {
  /// Apply for a new loan
  Future<Result<Loan>> applyForLoan({
    required String farmerId,
    required String cooperativeId,
    required double principalAmount,
    required double interestRate,
    required int termMonths,
    required String mfiPartnerId,
  });

  /// Get loan by ID
  Future<Result<Loan>> getLoanById(String loanId);

  /// Get all loans for a farmer
  Future<Result<List<Loan>>> getFarmerLoans(String farmerId);

  /// Get all loans for a cooperative
  Future<Result<List<Loan>>> getCooperativeLoans(String cooperativeId);

  /// Get pending loan applications
  Future<Result<List<Loan>>> getPendingLoans(String cooperativeId);

  /// Approve a loan
  Future<Result<Loan>> approveLoan(String loanId);

  /// Reject a loan
  Future<Result<Loan>> rejectLoan(String loanId, String reason);

  /// Disburse a loan
  Future<Result<Loan>> disburseLoan(String loanId);

  /// Process loan repayment
  Future<Result<LoanRepayment>> processRepayment({
    required String loanId,
    required double amount,
    required double principalPaid,
    required double interestPaid,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  });

  /// Get repayment history for a loan
  Future<Result<List<LoanRepayment>>> getLoanRepayments(String loanId);

  /// Update loan status
  Future<Result<Loan>> updateLoanStatus(String loanId, LoanStatus status);

  /// Stream of farmer loans
  Stream<List<Loan>> watchFarmerLoans(String farmerId);

  /// Stream of cooperative loans
  Stream<List<Loan>> watchCooperativeLoans(String cooperativeId);
}
