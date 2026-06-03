import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';

/// Use case for getting farmer details
class GetFarmerDetails {
  final FarmerRepository repository;

  GetFarmerDetails(this.repository);

  Future<Result<Farmer>> call(String farmerId) async {
    return await repository.getFarmerById(farmerId);
  }
}
