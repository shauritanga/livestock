import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for enrolling a farmer in livestock insurance
/// 
/// This use case handles the complete enrollment process:
/// 1. Validates that at least one cattle is selected
/// 2. Calculates the premium for selected cattle
/// 3. Creates the insurance policy
/// 
/// Requirements: 1.1, 1.2, 1.3, 1.7
class EnrollInsuranceUseCase {
  final InsuranceRepository repository;

  EnrollInsuranceUseCase(this.repository);

  /// Enrolls a farmer in insurance
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer to enroll
  /// - [cattleIds]: List of cattle IDs to cover
  /// - [paymentFrequency]: Monthly or quarterly payment schedule
  /// 
  /// Returns:
  /// - Success with the created InsurancePolicy
  /// - Error with ValidationFailure if inputs are invalid
  /// - Error with other Failure types from repository operations
  Future<Result<InsurancePolicy>> call({
    required String farmerId,
    required List<String> cattleIds,
    required PaymentFrequency paymentFrequency,
  }) async {
    // Validate farmer has cattle selected
    if (cattleIds.isEmpty) {
      return const Error(
        ValidationFailure('At least one cattle must be selected'),
      );
    }

    // Calculate premium for selected cattle
    final premiumResult = await repository.calculatePremium(
      farmerId: farmerId,
      cattleIds: cattleIds,
    );

    // Handle premium calculation result
    return premiumResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (premium) async {
        // Create policy with calculated premium
        return await repository.createPolicy(
          farmerId: farmerId,
          cattleIds: cattleIds,
          totalPremium: premium.totalAnnualPremium,
          paymentFrequency: paymentFrequency,
        );
      },
    );
  }
}
