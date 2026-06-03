import 'package:equatable/equatable.dart';

/// Loan repayment entity representing a payment made towards a loan
class LoanRepayment extends Equatable {
  final String id;
  final String loanId;
  final double amount;
  final double principalPaid;
  final double interestPaid;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? milkDeliveryId;

  const LoanRepayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.principalPaid,
    required this.interestPaid,
    required this.paymentDate,
    required this.paymentMethod,
    this.milkDeliveryId,
  });

  @override
  List<Object?> get props => [
        id,
        loanId,
        amount,
        principalPaid,
        interestPaid,
        paymentDate,
        paymentMethod,
        milkDeliveryId,
      ];
}

enum PaymentMethod {
  milkDeduction,
  mobileMoney,
}
