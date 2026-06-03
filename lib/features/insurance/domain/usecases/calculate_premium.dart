import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for calculating insurance premium
/// 
/// This use case calculates the premium for selected cattle based on
/// their characteristics (age, breed, health status) and premium rates.
/// 
/// Requirements: 1.4
class CalculatePremiumUseCase {
  final InsuranceRepository repository;

  CalculatePremiumUseCase(this.repository);

  /// Calculates premium for selected cattle
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// - [cattleIds]: List of cattle IDs to calculate premium for
  /// 
  /// Returns:
  /// - Success with PremiumCalculation containing breakdown
  /// - Error with ValidationFailure if inputs are invalid
  /// - Error with NotFoundFailure if cattle or rates not found
  /// - Error with ServerFailure if calculation fails
  Future<Result<PremiumCalculation>> call({
    required String farmerId,
    required List<String> cattleIds,
  }) async {
    return await repository.calculatePremium(
      farmerId: farmerId,
      cattleIds: cattleIds,
    );
  }
}
