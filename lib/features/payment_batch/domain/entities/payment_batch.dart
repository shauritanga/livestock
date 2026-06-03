import 'package:equatable/equatable.dart';

/// Payment batch status enum
enum PaymentBatchStatus {
  draft,
  processed,
}

/// Payment batch entity representing a monthly payment batch
class PaymentBatch extends Equatable {
  final String id;
  final String cooperativeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final PaymentBatchStatus status;
  final int totalFarmers;
  final double totalAmount;
  final DateTime? processedDate;
  final String? paymentMethod;
  final String? batchReference;
  final String createdBy;
  final DateTime createdAt;

  const PaymentBatch({
    required this.id,
    required this.cooperativeId,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.totalFarmers,
    required this.totalAmount,
    this.processedDate,
    this.paymentMethod,
    this.batchReference,
    required this.createdBy,
    required this.createdAt,
  });

  /// Check if batch is processed
  bool get isProcessed => status == PaymentBatchStatus.processed;

  /// Get period description
  String get periodDescription {
    final startStr = '${periodStart.day}/${periodStart.month}/${periodStart.year}';
    final endStr = '${periodEnd.day}/${periodEnd.month}/${periodEnd.year}';
    return '$startStr - $endStr';
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        periodStart,
        periodEnd,
        status,
        totalFarmers,
        totalAmount,
        processedDate,
        paymentMethod,
        batchReference,
        createdBy,
        createdAt,
      ];

  PaymentBatch copyWith({
    String? id,
    String? cooperativeId,
    DateTime? periodStart,
    DateTime? periodEnd,
    PaymentBatchStatus? status,
    int? totalFarmers,
    double? totalAmount,
    DateTime? processedDate,
    String? paymentMethod,
    String? batchReference,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return PaymentBatch(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      status: status ?? this.status,
      totalFarmers: totalFarmers ?? this.totalFarmers,
      totalAmount: totalAmount ?? this.totalAmount,
      processedDate: processedDate ?? this.processedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      batchReference: batchReference ?? this.batchReference,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
