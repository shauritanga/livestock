import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for verifying insurance eligibility for loan applications
/// 
/// This use case checks if a farmer meets insurance requirements for loans:
/// 1. Has at least one active insurance policy
/// 2. All productive cattle (lactating and pregnant) are covered
/// 3. No overdue premiums exceeding 30 days
/// 
/// Requirements: 8.1, 8.2, 8.3, 8.4
class VerifyInsuranceEligibilityUseCase {
  final InsuranceRepository insuranceRepository;
  final CattleRepository cattleRepository;

  VerifyInsuranceEligibilityUseCase({
    required this.insuranceRepository,
    required this.cattleRepository,
  });

  /// Verifies insurance eligibility for a farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer to verify
  /// 
  /// Returns:
  /// - Success with InsuranceEligibility indicating eligibility status
  /// - Error with ServerFailure if verification fails
  Future<Result<InsuranceEligibility>> call(String farmerId) async {
    // Get farmer's active policies
    final policiesResult =
        await insuranceRepository.getFarmerPolicies(farmerId);

    return policiesResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (allPolicies) async {
        // Filter for active policies only
        final activePolicies = allPolicies
            .where((p) => p.status == PolicyStatus.active)
            .toList();

        // Check if farmer has any active policy
        if (activePolicies.isEmpty) {
          return Success(InsuranceEligibility.noActivePolicy());
        }

        // Get farmer's cattle
        final cattleResult = await cattleRepository.getCattleByFarmer(farmerId);

        return cattleResult.fold(
          onError: (failure) => Error(failure),
          onSuccess: (allCattle) {
            // Filter for productive cattle (lactating or pregnant)
            final productiveCattle = allCattle
                .where(
                  (c) =>
                      c.lactationStatus == LactationStatus.lactating ||
                      c.lactationStatus == LactationStatus.pregnant,
                )
                .toList();

            // Get all covered cattle IDs from active policies
            final coveredCattleIds = activePolicies
                .expand((p) => p.coveredCattleIds)
                .toSet();

            // Find uncovered productive cattle
            final uncoveredCattle = productiveCattle
                .where((c) => !coveredCattleIds.contains(c.id))
                .toList();

            // Check if there are uncovered productive cattle
            if (uncoveredCattle.isNotEmpty) {
              return Success(
                InsuranceEligibility.uncoveredCattle(
                  uncoveredCattle.map((c) => c.id).toList(),
                ),
              );
            }

            // Check for overdue premiums (more than 30 days)
            final now = DateTime.now();
            final thirtyDaysAgo = now.subtract(const Duration(days: 30));

            final hasOverdue = activePolicies.any(
              (p) => p.nextPaymentDue.isBefore(thirtyDaysAgo),
            );

            if (hasOverdue) {
              return Success(InsuranceEligibility.overduePremiums());
            }

            // All checks passed - farmer is eligible
            return Success(InsuranceEligibility.eligible());
          },
        );
      },
    );
  }
}
