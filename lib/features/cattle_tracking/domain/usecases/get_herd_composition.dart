import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';

/// Use case for getting herd composition statistics
class GetHerdComposition {
  final CattleRepository repository;

  GetHerdComposition(this.repository);

  Future<Result<Map<String, int>>> call(String farmerId) async {
    return await repository.getHerdComposition(farmerId);
  }
}
