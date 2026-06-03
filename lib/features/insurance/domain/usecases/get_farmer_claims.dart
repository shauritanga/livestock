import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Use case for retrieving all insurance claims for a farmer
/// 
/// This use case fetches all claims (submitted, under review, approved,
/// rejected, settled) for a specific farmer.
/// 
/// Requirements: 6.1, 6.2
class GetFarmerClaimsUseCase {
  final InsuranceRepository repository;

  GetFarmerClaimsUseCase(this.repository);

  /// Gets all claims for a farmer
  /// 
  /// Parameters:
  /// - [farmerId]: The ID of the farmer
  /// 
  /// Returns:
  /// - Success with list of InsuranceClaim (empty list if none found)
  /// - Error with ServerFailure if retrieval fails
  Future<Result<List<InsuranceClaim>>> call(String farmerId) async {
    return await repository.getFarmerClaims(farmerId);
  }
}
