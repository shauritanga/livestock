import 'package:equatable/equatable.dart';

/// Loan entity representing an input loan for farmers
/// 
/// Supports two lending models:
/// - Direct: MFI to farmer
/// - Cooperative-intermediated: MFI to cooperative, cooperative to farmer
class Loan extends Equatable {
  final String id;
  final String farmerId;
  final String cooperativeId;
  final LendingModel lendingModel;
  final LoanType loanType;
  final double principalAmount;
  final double interestRate;
  final InterestType interestType;
  final int termMonths;
  final double outstandingBalance;
  final DateTime disbursementDate;
  final DateTime nextPaymentDue;
  final LoanStatus status;
  final String mfiPartnerId;
  final bool insuranceVerified;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const Loan({
    required this.id,
    required this.farmerId,
    required this.cooperativeId,
    required this.lendingModel,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.interestType,
    required this.termMonths,
    required this.outstandingBalance,
    required this.disbursementDate,
    required this.nextPaymentDue,
    required this.status,
    required this.mfiPartnerId,
    required this.insuranceVerified,
    required this.createdAt,
    this.approvedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
        id,
        farmerId,
        cooperativeId,
        lendingModel,
        loanType,
        principalAmount,
        interestRate,
        interestType,
        termMonths,
        outstandingBalance,
        disbursementDate,
        nextPaymentDue,
        status,
        mfiPartnerId,
        insuranceVerified,
        createdAt,
        approvedAt,
        rejectionReason,
      ];

  Loan copyWith({
    String? id,
    String? farmerId,
    String? cooperativeId,
    LendingModel? lendingModel,
    LoanType? loanType,
    double? principalAmount,
    double? interestRate,
    InterestType? interestType,
    int? termMonths,
    double? outstandingBalance,
    DateTime? disbursementDate,
    DateTime? nextPaymentDue,
    LoanStatus? status,
    String? mfiPartnerId,
    bool? insuranceVerified,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return Loan(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      lendingModel: lendingModel ?? this.lendingModel,
      loanType: loanType ?? this.loanType,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      interestType: interestType ?? this.interestType,
      termMonths: termMonths ?? this.termMonths,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      disbursementDate: disbursementDate ?? this.disbursementDate,
      nextPaymentDue: nextPaymentDue ?? this.nextPaymentDue,
      status: status ?? this.status,
      mfiPartnerId: mfiPartnerId ?? this.mfiPartnerId,
      insuranceVerified: insuranceVerified ?? this.insuranceVerified,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

enum LendingModel {
  direct,
  cooperativeIntermediated,
}

enum LoanType {
  inputLoan,
}

enum InterestType {
  flat,
  reducingBalance,
}

enum LoanStatus {
  pending,
  approved,
  disbursed,
  active,
  completed,
  defaulted,
  rejected,
}
