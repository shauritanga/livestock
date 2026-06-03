import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/loan_remote_datasource.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../domain/usecases/apply_for_loan.dart';
import '../../domain/usecases/approve_loan.dart';
import '../../domain/usecases/get_farmer_loans.dart';
import '../../domain/usecases/get_loan_details.dart';
import '../../domain/usecases/get_loan_repayments.dart';
import '../../domain/usecases/process_repayment.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for loan remote data source
final loanRemoteDataSourceProvider = Provider<LoanRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return LoanRemoteDataSource(firestore: firestore);
});

/// Provider for loan repository
final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final remoteDataSource = ref.watch(loanRemoteDataSourceProvider);
  return LoanRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for apply for loan use case
final applyForLoanProvider = Provider<ApplyForLoan>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return ApplyForLoan(repository);
});

/// Provider for approve loan use case
final approveLoanProvider = Provider<ApproveLoan>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return ApproveLoan(repository);
});

/// Provider for get farmer loans use case
final getFarmerLoansProvider = Provider<GetFarmerLoans>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return GetFarmerLoans(repository);
});

/// Provider for get loan details use case
final getLoanDetailsProvider = Provider<GetLoanDetails>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return GetLoanDetails(repository);
});

/// Provider for process repayment use case
final processRepaymentProvider = Provider<ProcessRepayment>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return ProcessRepayment(repository);
});

/// Provider for get loan repayments use case
final getLoanRepaymentsProvider = Provider<GetLoanRepayments>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return GetLoanRepayments(repository);
});
