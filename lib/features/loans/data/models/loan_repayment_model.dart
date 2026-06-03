import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan_repayment.dart';

/// Firestore model for LoanRepayment entity
class LoanRepaymentModel {
  final String id;
  final String loanId;
  final double amount;
  final double principalPaid;
  final double interestPaid;
  final Timestamp paymentDate;
  final String paymentMethod;
  final String? milkDeliveryId;

  LoanRepaymentModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.principalPaid,
    required this.interestPaid,
    required this.paymentDate,
    required this.paymentMethod,
    this.milkDeliveryId,
  });

  /// Convert from Firestore document
  factory LoanRepaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoanRepaymentModel(
      id: doc.id,
      loanId: data['loanId'] as String,
      amount: (data['amount'] as num).toDouble(),
      principalPaid: (data['principalPaid'] as num).toDouble(),
      interestPaid: (data['interestPaid'] as num).toDouble(),
      paymentDate: data['paymentDate'] as Timestamp,
      paymentMethod: data['paymentMethod'] as String,
      milkDeliveryId: data['milkDeliveryId'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'loanId': loanId,
      'amount': amount,
      'principalPaid': principalPaid,
      'interestPaid': interestPaid,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'milkDeliveryId': milkDeliveryId,
    };
  }

  /// Convert to domain entity
  LoanRepayment toEntity() {
    return LoanRepayment(
      id: id,
      loanId: loanId,
      amount: amount,
      principalPaid: principalPaid,
      interestPaid: interestPaid,
      paymentDate: paymentDate.toDate(),
      paymentMethod: _parsePaymentMethod(paymentMethod),
      milkDeliveryId: milkDeliveryId,
    );
  }

  /// Convert from domain entity
  factory LoanRepaymentModel.fromEntity(LoanRepayment repayment) {
    return LoanRepaymentModel(
      id: repayment.id,
      loanId: repayment.loanId,
      amount: repayment.amount,
      principalPaid: repayment.principalPaid,
      interestPaid: repayment.interestPaid,
      paymentDate: Timestamp.fromDate(repayment.paymentDate),
      paymentMethod: _paymentMethodToString(repayment.paymentMethod),
      milkDeliveryId: repayment.milkDeliveryId,
    );
  }

  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'milk_deduction':
        return PaymentMethod.milkDeduction;
      case 'mobile_money':
        return PaymentMethod.mobileMoney;
      default:
        return PaymentMethod.milkDeduction;
    }
  }

  static String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.milkDeduction:
        return 'milk_deduction';
      case PaymentMethod.mobileMoney:
        return 'mobile_money';
    }
  }
}
