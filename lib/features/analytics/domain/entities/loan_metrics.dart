import 'package:equatable/equatable.dart';

/// Loan performance metrics
class LoanMetrics extends Equatable {
  final double totalDisbursed;
  final double totalOutstanding;
  final double repaymentRate;
  final double defaultRate;
  final int activeLoanCount;
  final int completedLoanCount;
  final int defaultedLoanCount;

  const LoanMetrics({
    required this.totalDisbursed,
    required this.totalOutstanding,
    required this.repaymentRate,
    required this.defaultRate,
    required this.activeLoanCount,
    required this.completedLoanCount,
    required this.defaultedLoanCount,
  });

  /// Total loans (all statuses)
  int get totalLoans =>
      activeLoanCount + completedLoanCount + defaultedLoanCount;

  /// Total repaid amount
  double get totalRepaid => totalDisbursed - totalOutstanding;

  /// Repayment percentage
  double get repaymentPercentage =>
      totalDisbursed > 0 ? (totalRepaid / totalDisbursed) * 100 : 0;

  /// Active loan percentage
  double get activeLoanPercentage =>
      totalLoans > 0 ? (activeLoanCount / totalLoans) * 100 : 0;

  /// Completed loan percentage
  double get completedLoanPercentage =>
      totalLoans > 0 ? (completedLoanCount / totalLoans) * 100 : 0;

  /// Average loan size
  double get averageLoanSize =>
      totalLoans > 0 ? totalDisbursed / totalLoans : 0;

  /// Risk level based on default rate
  String get riskLevel {
    if (defaultRate < 5) return 'Low';
    if (defaultRate < 10) return 'Medium';
    if (defaultRate < 20) return 'High';
    return 'Critical';
  }

  @override
  List<Object?> get props => [
        totalDisbursed,
        totalOutstanding,
        repaymentRate,
        defaultRate,
        activeLoanCount,
        completedLoanCount,
        defaultedLoanCount,
      ];

  LoanMetrics copyWith({
    double? totalDisbursed,
    double? totalOutstanding,
    double? repaymentRate,
    double? defaultRate,
    int? activeLoanCount,
    int? completedLoanCount,
    int? defaultedLoanCount,
  }) {
    return LoanMetrics(
      totalDisbursed: totalDisbursed ?? this.totalDisbursed,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      repaymentRate: repaymentRate ?? this.repaymentRate,
      defaultRate: defaultRate ?? this.defaultRate,
      activeLoanCount: activeLoanCount ?? this.activeLoanCount,
      completedLoanCount: completedLoanCount ?? this.completedLoanCount,
      defaultedLoanCount: defaultedLoanCount ?? this.defaultedLoanCount,
    );
  }
}
