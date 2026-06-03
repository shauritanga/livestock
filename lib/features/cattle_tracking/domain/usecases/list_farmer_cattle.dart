import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';

/// Use case for listing cattle by farmer
class ListFarmerCattle {
  final CattleRepository repository;

  ListFarmerCattle(this.repository);

  Future<Result<List<Cattle>>> call(String farmerId) async {
    return await repository.getCattleByFarmer(farmerId);
  }
}
