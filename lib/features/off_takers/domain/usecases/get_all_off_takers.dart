import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/repositories/off_taker_repository.dart';

/// Use case for retrieving all off-takers with optional category filter (MVP)
class GetAllOffTakers {
  final OffTakerRepository repository;

  GetAllOffTakers(this.repository);

  Future<Result<List<OffTaker>>> call({
    OffTakerCategory? category,
  }) async {
    return repository.getAllOffTakers(category: category);
  }
}
