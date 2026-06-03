import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan.dart';

/// Firestore model for Loan entity
class LoanModel {
  final String id;
  final String farmerId;
  final String cooperativeId;
  final String lendingModel;
  final String loanType;
  final double principalAmount;
  final double interestRate;
  final String interestType;
  final int termMonths;
  final double outstandingBalance;
  final Timestamp disbursementDate;
  final Timestamp nextPaymentDue;
  final String status;
  final String mfiPartnerId;
  final bool insuranceVerified;
  final Timestamp createdAt;
  final Timestamp? approvedAt;
  final String? rejectionReason;

  LoanModel({
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

  /// Convert from Firestore document
  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoanModel(
      id: doc.id,
      farmerId: data['farmerId'] as String,
      cooperativeId: data['cooperativeId'] as String,
      lendingModel: data['lendingModel'] as String,
      loanType: data['loanType'] as String,
      principalAmount: (data['principalAmount'] as num).toDouble(),
      interestRate: (data['interestRate'] as num).toDouble(),
      interestType: data['interestType'] as String,
      termMonths: data['termMonths'] as int,
      outstandingBalance: (data['outstandingBalance'] as num).toDouble(),
      disbursementDate: data['disbursementDate'] as Timestamp,
      nextPaymentDue: data['nextPaymentDue'] as Timestamp,
      status: data['status'] as String,
      mfiPartnerId: data['mfiPartnerId'] as String,
      insuranceVerified: data['insuranceVerified'] as bool,
      createdAt: data['createdAt'] as Timestamp,
      approvedAt: data['approvedAt'] as Timestamp?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'farmerId': farmerId,
      'cooperativeId': cooperativeId,
      'lendingModel': lendingModel,
      'loanType': loanType,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'interestType': interestType,
      'termMonths': termMonths,
      'outstandingBalance': outstandingBalance,
      'disbursementDate': disbursementDate,
      'nextPaymentDue': nextPaymentDue,
      'status': status,
      'mfiPartnerId': mfiPartnerId,
      'insuranceVerified': insuranceVerified,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
      'rejectionReason': rejectionReason,
    };
  }

  /// Convert to domain entity
  Loan toEntity() {
    return Loan(
      id: id,
      farmerId: farmerId,
      cooperativeId: cooperativeId,
      lendingModel: _parseLendingModel(lendingModel),
      loanType: _parseLoanType(loanType),
      principalAmount: principalAmount,
      interestRate: interestRate,
      interestType: _parseInterestType(interestType),
      termMonths: termMonths,
      outstandingBalance: outstandingBalance,
      disbursementDate: disbursementDate.toDate(),
      nextPaymentDue: nextPaymentDue.toDate(),
      status: _parseStatus(status),
      mfiPartnerId: mfiPartnerId,
      insuranceVerified: insuranceVerified,
      createdAt: createdAt.toDate(),
      approvedAt: approvedAt?.toDate(),
      rejectionReason: rejectionReason,
    );
  }

  /// Convert from domain entity
  factory LoanModel.fromEntity(Loan loan) {
    return LoanModel(
      id: loan.id,
      farmerId: loan.farmerId,
      cooperativeId: loan.cooperativeId,
      lendingModel: _lendingModelToString(loan.lendingModel),
      loanType: _loanTypeToString(loan.loanType),
      principalAmount: loan.principalAmount,
      interestRate: loan.interestRate,
      interestType: _interestTypeToString(loan.interestType),
      termMonths: loan.termMonths,
      outstandingBalance: loan.outstandingBalance,
      disbursementDate: Timestamp.fromDate(loan.disbursementDate),
      nextPaymentDue: Timestamp.fromDate(loan.nextPaymentDue),
      status: _statusToString(loan.status),
      mfiPartnerId: loan.mfiPartnerId,
      insuranceVerified: loan.insuranceVerified,
      createdAt: Timestamp.fromDate(loan.createdAt),
      approvedAt: loan.approvedAt != null ? Timestamp.fromDate(loan.approvedAt!) : null,
      rejectionReason: loan.rejectionReason,
    );
  }

  static LendingModel _parseLendingModel(String value) {
    switch (value) {
      case 'direct':
        return LendingModel.direct;
      case 'cooperative_intermediated':
        return LendingModel.cooperativeIntermediated;
      default:
        return LendingModel.direct;
    }
  }

  static String _lendingModelToString(LendingModel model) {
    switch (model) {
      case LendingModel.direct:
        return 'direct';
      case LendingModel.cooperativeIntermediated:
        return 'cooperative_intermediated';
    }
  }

  static LoanType _parseLoanType(String value) {
    return LoanType.inputLoan;
  }

  static String _loanTypeToString(LoanType type) {
    return 'input_loan';
  }

  static InterestType _parseInterestType(String value) {
    switch (value) {
      case 'flat':
        return InterestType.flat;
      case 'reducing_balance':
        return InterestType.reducingBalance;
      default:
        return InterestType.flat;
    }
  }

  static String _interestTypeToString(InterestType type) {
    switch (type) {
      case InterestType.flat:
        return 'flat';
      case InterestType.reducingBalance:
        return 'reducing_balance';
    }
  }

  static LoanStatus _parseStatus(String value) {
    switch (value) {
      case 'pending':
        return LoanStatus.pending;
      case 'approved':
        return LoanStatus.approved;
      case 'disbursed':
        return LoanStatus.disbursed;
      case 'active':
        return LoanStatus.active;
      case 'completed':
        return LoanStatus.completed;
      case 'defaulted':
        return LoanStatus.defaulted;
      case 'rejected':
        return LoanStatus.rejected;
      default:
        return LoanStatus.pending;
    }
  }

  static String _statusToString(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return 'pending';
      case LoanStatus.approved:
        return 'approved';
      case LoanStatus.disbursed:
        return 'disbursed';
      case LoanStatus.active:
        return 'active';
      case LoanStatus.completed:
        return 'completed';
      case LoanStatus.defaulted:
        return 'defaulted';
      case LoanStatus.rejected:
        return 'rejected';
    }
  }
}
