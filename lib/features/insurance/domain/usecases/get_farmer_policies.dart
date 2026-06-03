import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for retrieving all insurance policies for a farmer
/// 
/// This use case fetches all policies (active, expired, suspended, cancelled)
/// for a specific farmer.
/// 
/// Requirements: 3.2, 3.3
class GetFarmerPoliciesUseCase {
  final InsuranceRepository repository;

  GetFarmerPoliciesUseCase(this.repository);

  /// Gets all policies for a farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// 
  /// Returns:
  /// - Success with list of InsurancePolicy (empty list if none found)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsurancePolicy>>> call(String farmerId) async {
    return await repository.getFarmerPolicies(farmerId);
  }
}
