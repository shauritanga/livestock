import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';

/// Use case for registering a new farmer
class RegisterFarmer {
  final FarmerRepository repository;

  RegisterFarmer(this.repository);

  Future<Result<Farmer>> call(Farmer farmer) async {
    return await repository.registerFarmer(farmer);
  }
}
