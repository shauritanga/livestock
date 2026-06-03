import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';

/// Use case for updating cattle information
class UpdateCattle {
  final CattleRepository repository;

  UpdateCattle(this.repository);

  Future<Result<Cattle>> call(Cattle cattle) async {
    return await repository.updateCattle(cattle);
  }
}
