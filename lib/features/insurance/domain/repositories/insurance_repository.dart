import 'dart:io';

import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';

/// Repository interface for insurance operations
/// 
/// This interface defines all operations related to insurance policies,
/// premium calculations, payments, and claims management.
/// All methods return Result<T> for consistent error handling.
abstract class InsuranceRepository {
  // ==================== Policy Management ====================
  
  /// Creates a new insurance policy for a farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer enrolling in insurance
  /// - [cattleIds]: List of cattle IDs to be covered
  /// - [totalPremium]: Total annual premium amount
  /// - [paymentFrequency]: Monthly or quarterly payment schedule
  /// 
  /// Returns:
  /// - Success with the created InsurancePolicy
  /// - Error with ValidationFailure if inputs are invalid
  /// - Error with ServerFailure if creation fails
  Future<Result<InsurancePolicy>> createPolicy({
    required String farmerId,
    required List<String> cattleIds,
    required double totalPremium,
    required PaymentFrequency paymentFrequency,
  });

  /// Retrieves a specific insurance policy by ID
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// 
  /// Returns:
  /// - Success with the InsurancePolicy
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if retrieval fails
  Future<Result<InsurancePolicy>> getPolicy(String policyId);

  /// Retrieves all insurance policies for a specific farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// 
  /// Returns:
  /// - Success with list of InsurancePolicy (empty list if none found)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsurancePolicy>>> getFarmerPolicies(
    String farmerId,
  );

  /// Retrieves all policies with a specific status
  /// 
  /// Parameters:
  /// - [status]: The policy status to filter by
  /// 
  /// Returns:
  /// - Success with list of InsurancePolicy (empty list if none found)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsurancePolicy>>> getPoliciesByStatus(
    PolicyStatus status,
  );

  /// Updates the status of an insurance policy
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// - [status]: The new status to set
  /// 
  /// Returns:
  /// - Success with the updated InsurancePolicy
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if update fails
  Future<Result<InsurancePolicy>> updatePolicyStatus(
    String policyId,
    PolicyStatus status,
  );

  // ==================== Premium Calculation ====================
  
  /// Calculates insurance premium for selected cattle
  /// 
  /// This method fetches cattle details, applies premium rates based on
  /// age, breed, and health status, and returns the calculation breakdown.
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// - [cattleIds]: List of cattle IDs to calculate premium for
  /// 
  /// Returns:
  /// - Success with PremiumCalculation containing breakdown
  /// - Error with ValidationFailure if cattle IDs are invalid
  /// - Error with NotFoundFailure if cattle or rates not found
  /// - Error with ServerFailure if calculation fails
  Future<Result<PremiumCalculation>> calculatePremium({
    required String farmerId,
    required List<String> cattleIds,
  });

  // ==================== Premium Payments ====================
  
  /// Records a premium payment for a policy
  /// 
  /// This method creates a payment record and updates the policy's
  /// payment status, total paid, and next payment due date.
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// - [amount]: The payment amount
  /// - [paymentMethod]: How the payment was made
  /// - [milkDeliveryId]: Optional ID if payment was from milk deduction
  /// 
  /// Returns:
  /// - Success with void on successful recording
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ValidationFailure if amount is invalid
  /// - Error with ServerFailure if recording fails
  Future<Result<void>> recordPremiumPayment({
    required String policyId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  });

  /// Retrieves all premium payments for a specific policy
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// 
  /// Returns:
  /// - Success with list of PremiumPayment (empty list if none found)
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<PremiumPayment>>> getPolicyPayments(
    String policyId,
  );

  // ==================== Claims Management ====================
  
  /// Creates a new insurance claim for livestock loss
  /// 
  /// This method creates a claim record, uploads supporting documents,
  /// and notifies the insurance partner.
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// - [cattleId]: The ID of the lost cattle
  /// - [lossType]: Type of loss (death, theft, disease)
  /// - [lossDate]: Date when the loss occurred
  /// - [description]: Detailed description of circumstances
  /// - [supportingDocuments]: List of document URLs (already uploaded)
  /// 
  /// Returns:
  /// - Success with the created InsuranceClaim
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ValidationFailure if inputs are invalid
  /// - Error with ServerFailure if creation fails
  Future<Result<InsuranceClaim>> createClaim({
    required String policyId,
    required String cattleId,
    required LossType lossType,
    required DateTime lossDate,
    required String description,
    required List<String> supportingDocuments,
  });

  /// Retrieves a specific insurance claim by ID
  /// 
  /// Parameters:
  /// - [claimId]: The unique identifier of the claim
  /// 
  /// Returns:
  /// - Success with the InsuranceClaim
  /// - Error with NotFoundFailure if claim doesn't exist
  /// - Error with ServerFailure if retrieval fails
  Future<Result<InsuranceClaim>> getClaim(String claimId);

  /// Retrieves all claims for a specific farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// 
  /// Returns:
  /// - Success with list of InsuranceClaim (empty list if none found)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsuranceClaim>>> getFarmerClaims(
    String farmerId,
  );

  /// Retrieves all claims for a specific policy
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// 
  /// Returns:
  /// - Success with list of InsuranceClaim (empty list if none found)
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsuranceClaim>>> getPolicyClaims(
    String policyId,
  );

  // ==================== Document Management ====================
  
  /// Uploads a document to Firebase Storage
  /// 
  /// This method uploads a file (photo, report, etc.) and returns
  /// the download URL for storage in claim records.
  /// 
  /// Parameters:
  /// - [document]: The file to upload
  /// 
  /// Returns:
  /// - Success with the download URL string
  /// - Error with ValidationFailure if file is invalid
  /// - Error with ServerFailure if upload fails
  Future<Result<String>> uploadDocument(File document);

  // ==================== Premium Rates ====================
  
  /// Retrieves all active premium rate configurations
  /// 
  /// Premium rates are used to calculate insurance premiums based on
  /// cattle characteristics (age, breed, health status).
  /// 
  /// Returns:
  /// - Success with list of PremiumRate (empty list if none configured)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<PremiumRate>>> getPremiumRates();
}

/// Represents a premium rate configuration
/// 
/// This is a simple data class used by the repository.
/// The full model will be defined in the data layer.
class PremiumRate {
  final String id;
  final int minAge;
  final int maxAge;
  final String breedCategory;
  final String healthStatus;
  final double baseRate;
  final DateTime effectiveDate;
  final bool isActive;

  const PremiumRate({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.breedCategory,
    required this.healthStatus,
    required this.baseRate,
    required this.effectiveDate,
    required this.isActive,
  });
}
