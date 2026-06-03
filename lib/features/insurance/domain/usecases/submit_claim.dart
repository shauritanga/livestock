import 'dart:io';

import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for submitting an insurance claim
/// 
/// This use case handles the complete claim submission process:
/// 1. Validates the policy is active
/// 2. Verifies the cattle is covered by the policy
/// 3. Uploads supporting documents
/// 4. Creates the claim record
/// 
/// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5
class SubmitClaimUseCase {
  final InsuranceRepository repository;

  SubmitClaimUseCase(this.repository);

  /// Submits an insurance claim
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// - [cattleId]: The ID of the lost cattle
  /// - [lossType]: Type of loss (death, theft, disease)
  /// - [lossDate]: Date when the loss occurred
  /// - [description]: Detailed description of circumstances
  /// - [supportingDocuments]: List of document files to upload
  /// 
  /// Returns:
  /// - Success with the created InsuranceClaim
  /// - Error with ValidationFailure if inputs are invalid
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if submission fails
  Future<Result<InsuranceClaim>> call({
    required String policyId,
    required String cattleId,
    required LossType lossType,
    required DateTime lossDate,
    required String description,
    required List<File> supportingDocuments,
  }) async {
    // Validate policy is active
    final policyResult = await repository.getPolicy(policyId);

    return policyResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (policy) async {
        // Check policy status
        if (policy.status != PolicyStatus.active) {
          return const Error(
            ValidationFailure('Policy is not active'),
          );
        }

        // Verify cattle is covered
        if (!policy.coveredCattleIds.contains(cattleId)) {
          return const Error(
            ValidationFailure('Cattle is not covered by this policy'),
          );
        }

        // Upload supporting documents
        final documentUrls = <String>[];
        for (final doc in supportingDocuments) {
          final uploadResult = await repository.uploadDocument(doc);

          // Handle upload result
          final url = uploadResult.fold(
            onError: (failure) => null,
            onSuccess: (url) => url,
          );

          // Return error if upload failed
          if (url == null) {
            return uploadResult as Error<InsuranceClaim>;
          }

          documentUrls.add(url);
        }

        // Create claim with uploaded document URLs
        return await repository.createClaim(
          policyId: policyId,
          cattleId: cattleId,
          lossType: lossType,
          lossDate: lossDate,
          description: description,
          supportingDocuments: documentUrls,
        );
      },
    );
  }
}
