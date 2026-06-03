import 'package:equatable/equatable.dart';

/// Represents an insurance claim for livestock loss
class InsuranceClaim extends Equatable {
  final String id;
  final String policyId;
  final String cattleId;
  final String farmerId;
  final LossType lossType;
  final DateTime lossDate;
  final String description;
  final double claimAmount;
  final DateTime submittedDate;
  final ClaimStatus status;
  final List<ClaimStatusUpdate> statusUpdates;
  final double? settlementAmount;
  final DateTime? settlementDate;
  final List<String> supportingDocuments;
  final String submittedBy;
  final String? reviewedBy;
  final String? reviewComments;

  const InsuranceClaim({
    required this.id,
    required this.policyId,
    required this.cattleId,
    required this.farmerId,
    required this.lossType,
    required this.lossDate,
    required this.description,
    required this.claimAmount,
    required this.submittedDate,
    required this.status,
    required this.statusUpdates,
    this.settlementAmount,
    this.settlementDate,
    required this.supportingDocuments,
    required this.submittedBy,
    this.reviewedBy,
    this.reviewComments,
  });

  @override
  List<Object?> get props => [
        id,
        policyId,
        status,
        submittedDate,
      ];

  /// Creates a copy of this claim with the given fields replaced
  InsuranceClaim copyWith({
    String? id,
    String? policyId,
    String? cattleId,
    String? farmerId,
    LossType? lossType,
    DateTime? lossDate,
    String? description,
    double? claimAmount,
    DateTime? submittedDate,
    ClaimStatus? status,
    List<ClaimStatusUpdate>? statusUpdates,
    double? settlementAmount,
    DateTime? settlementDate,
    List<String>? supportingDocuments,
    String? submittedBy,
    String? reviewedBy,
    String? reviewComments,
  }) {
    return InsuranceClaim(
      id: id ?? this.id,
      policyId: policyId ?? this.policyId,
      cattleId: cattleId ?? this.cattleId,
      farmerId: farmerId ?? this.farmerId,
      lossType: lossType ?? this.lossType,
      lossDate: lossDate ?? this.lossDate,
      description: description ?? this.description,
      claimAmount: claimAmount ?? this.claimAmount,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      settlementDate: settlementDate ?? this.settlementDate,
      supportingDocuments: supportingDocuments ?? this.supportingDocuments,
      submittedBy: submittedBy ?? this.submittedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }

  /// Checks if the claim is pending (submitted or under review)
  bool get isPending =>
      status == ClaimStatus.submitted || status == ClaimStatus.underReview;

  /// Checks if the claim is approved
  bool get isApproved => status == ClaimStatus.approved;

  /// Checks if the claim is settled
  bool get isSettled => status == ClaimStatus.settled;

  /// Checks if the claim is rejected
  bool get isRejected => status == ClaimStatus.rejected;

  /// Gets the latest status update
  ClaimStatusUpdate? get latestStatusUpdate {
    if (statusUpdates.isEmpty) return null;
    return statusUpdates.last;
  }
}

/// Type of livestock loss
enum LossType {
  death,
  theft,
  disease;

  /// Returns a human-readable label for the loss type
  String get label {
    switch (this) {
      case LossType.death:
        return 'Death';
      case LossType.theft:
        return 'Theft';
      case LossType.disease:
        return 'Disease';
    }
  }

  /// Returns an icon name for the loss type
  String get iconName {
    switch (this) {
      case LossType.death:
        return 'dangerous';
      case LossType.theft:
        return 'security';
      case LossType.disease:
        return 'medical_services';
    }
  }
}

/// Status of an insurance claim
enum ClaimStatus {
  submitted,
  underReview,
  approved,
  rejected,
  settled;

  /// Returns a human-readable label for the status
  String get label {
    switch (this) {
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.settled:
        return 'Settled';
    }
  }

  /// Returns true if the status is final (approved, rejected, or settled)
  bool get isFinal =>
      this == ClaimStatus.approved ||
      this == ClaimStatus.rejected ||
      this == ClaimStatus.settled;
}

/// Represents a status update in the claim processing timeline
class ClaimStatusUpdate extends Equatable {
  final ClaimStatus status;
  final DateTime date;
  final String comment;

  const ClaimStatusUpdate({
    required this.status,
    required this.date,
    required this.comment,
  });

  @override
  List<Object?> get props => [status, date];

  /// Creates a copy of this status update with the given fields replaced
  ClaimStatusUpdate copyWith({
    ClaimStatus? status,
    DateTime? date,
    String? comment,
  }) {
    return ClaimStatusUpdate(
      status: status ?? this.status,
      date: date ?? this.date,
      comment: comment ?? this.comment,
    );
  }
}
