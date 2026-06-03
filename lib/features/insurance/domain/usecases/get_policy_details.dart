import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for retrieving complete policy details
/// 
/// This use case fetches:
/// - The insurance policy
/// - Covered cattle details
/// - Premium payment history
/// 
/// Requirements: 3.2, 3.3, 3.4
class GetPolicyDetailsUseCase {
  final InsuranceRepository insuranceRepository;
  final CattleRepository cattleRepository;

  GetPolicyDetailsUseCase({
    required this.insuranceRepository,
    required this.cattleRepository,
  });

  /// Gets complete policy details
  /// 
  /// Parameters:
  /// - [policyId]: The unique identifier of the policy
  /// 
  /// Returns:
  /// - Success with PolicyDetails containing all information
  /// - Error with NotFoundFailure if policy doesn't exist
  /// - Error with ServerFailure if retrieval fails
  Future<Result<PolicyDetails>> call(String policyId) async {
    // Get the policy
    final policyResult = await insuranceRepository.getPolicy(policyId);

    return policyResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (policy) async {
        // Get covered cattle details
        final cattleResults = await Future.wait(
          policy.coveredCattleIds.map(
            (cattleId) => cattleRepository.getCattleById(cattleId),
          ),
        );

        // Extract successful cattle results
        final coveredCattle = <Cattle>[];
        for (final result in cattleResults) {
          if (result is Success<Cattle>) {
            coveredCattle.add(result.value);
          }
        }

        // Get payment history
        final paymentsResult =
            await insuranceRepository.getPolicyPayments(policyId);

        final payments = paymentsResult.fold(
          onError: (_) => <PremiumPayment>[],
          onSuccess: (payments) => payments,
        );

        // Return combined details
        return Success(
          PolicyDetails(
            policy: policy,
            coveredCattle: coveredCattle,
            paymentHistory: payments,
          ),
        );
      },
    );
  }
}

/// Combined policy details including cattle and payment history
class PolicyDetails {
  final InsurancePolicy policy;
  final List<Cattle> coveredCattle;
  final List<PremiumPayment> paymentHistory;

  const PolicyDetails({
    required this.policy,
    required this.coveredCattle,
    required this.paymentHistory,
  });
}
