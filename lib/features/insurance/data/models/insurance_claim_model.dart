import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';

/// Insurance claim model for Firestore serialization
class InsuranceClaimModel extends InsuranceClaim {
  const InsuranceClaimModel({
    required super.id,
    required super.policyId,
    required super.cattleId,
    required super.farmerId,
    required super.lossType,
    required super.lossDate,
    required super.description,
    required super.claimAmount,
    required super.submittedDate,
    required super.status,
    required super.statusUpdates,
    super.settlementAmount,
    super.settlementDate,
    required super.supportingDocuments,
    required super.submittedBy,
    super.reviewedBy,
    super.reviewComments,
  });

  /// Convert Firestore document to InsuranceClaimModel
  factory InsuranceClaimModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse status updates
    final statusUpdatesData = data['statusUpdates'] as List? ?? [];
    final statusUpdates = statusUpdatesData.map((update) {
      return ClaimStatusUpdate(
        status: ClaimStatus.values.firstWhere(
          (e) => e.name == update['status'],
          orElse: () => ClaimStatus.submitted,
        ),
        date: (update['date'] as Timestamp).toDate(),
        comment: update['comment'] as String,
      );
    }).toList();

    return InsuranceClaimModel(
      id: doc.id,
      policyId: data['policyId'] as String,
      cattleId: data['cattleId'] as String,
      farmerId: data['farmerId'] as String,
      lossType: LossType.values.firstWhere(
        (e) => e.name == data['lossType'],
        orElse: () => LossType.death,
      ),
      lossDate: (data['lossDate'] as Timestamp).toDate(),
      description: data['description'] as String,
      claimAmount: (data['claimAmount'] as num).toDouble(),
      submittedDate: (data['submittedDate'] as Timestamp).toDate(),
      status: ClaimStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ClaimStatus.submitted,
      ),
      statusUpdates: statusUpdates,
      settlementAmount: data['settlementAmount'] != null
          ? (data['settlementAmount'] as num).toDouble()
          : null,
      settlementDate: data['settlementDate'] != null
          ? (data['settlementDate'] as Timestamp).toDate()
          : null,
      supportingDocuments:
          List<String>.from(data['supportingDocuments'] as List? ?? []),
      submittedBy: data['submittedBy'] as String,
      reviewedBy: data['reviewedBy'] as String?,
      reviewComments: data['reviewComments'] as String?,
    );
  }

  /// Convert InsuranceClaimModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'policyId': policyId,
      'cattleId': cattleId,
      'farmerId': farmerId,
      'lossType': lossType.name,
      'lossDate': Timestamp.fromDate(lossDate),
      'description': description,
      'claimAmount': claimAmount,
      'submittedDate': Timestamp.fromDate(submittedDate),
      'status': status.name,
      'statusUpdates': statusUpdates
          .map((update) => {
                'status': update.status.name,
                'date': Timestamp.fromDate(update.date),
                'comment': update.comment,
              })
          .toList(),
      'settlementAmount': settlementAmount,
      'settlementDate':
          settlementDate != null ? Timestamp.fromDate(settlementDate!) : null,
      'supportingDocuments': supportingDocuments,
      'submittedBy': submittedBy,
      'reviewedBy': reviewedBy,
      'reviewComments': reviewComments,
    };
  }

  /// Convert InsuranceClaim entity to InsuranceClaimModel
  factory InsuranceClaimModel.fromEntity(InsuranceClaim claim) {
    return InsuranceClaimModel(
      id: claim.id,
      policyId: claim.policyId,
      cattleId: claim.cattleId,
      farmerId: claim.farmerId,
      lossType: claim.lossType,
      lossDate: claim.lossDate,
      description: claim.description,
      claimAmount: claim.claimAmount,
      submittedDate: claim.submittedDate,
      status: claim.status,
      statusUpdates: claim.statusUpdates,
      settlementAmount: claim.settlementAmount,
      settlementDate: claim.settlementDate,
      supportingDocuments: claim.supportingDocuments,
      submittedBy: claim.submittedBy,
      reviewedBy: claim.reviewedBy,
      reviewComments: claim.reviewComments,
    );
  }

  /// Convert InsuranceClaimModel to InsuranceClaim entity
  InsuranceClaim toEntity() {
    return InsuranceClaim(
      id: id,
      policyId: policyId,
      cattleId: cattleId,
      farmerId: farmerId,
      lossType: lossType,
      lossDate: lossDate,
      description: description,
      claimAmount: claimAmount,
      submittedDate: submittedDate,
      status: status,
      statusUpdates: statusUpdates,
      settlementAmount: settlementAmount,
      settlementDate: settlementDate,
      supportingDocuments: supportingDocuments,
      submittedBy: submittedBy,
      reviewedBy: reviewedBy,
      reviewComments: reviewComments,
    );
  }
}
