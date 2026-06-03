import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/repositories/off_taker_repository.dart';

/// Use case for retrieving an off-taker by ID
class GetOffTakerById {
  final OffTakerRepository repository;

  GetOffTakerById(this.repository);

  Future<Result<OffTaker?>> call(String id) async {
    return repository.getOffTakerById(id);
  }
}
