import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';

/// Use case for getting cattle details
class GetCattleDetails {
  final CattleRepository repository;

  GetCattleDetails(this.repository);

  Future<Result<Cattle>> call(String cattleId) async {
    return await repository.getCattleById(cattleId);
  }
}
