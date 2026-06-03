import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';

/// Repository interface for off-taker management (MVP - simplified)
abstract class OffTakerRepository {
  /// Create a new off-taker
  Future<Result<OffTaker>> createOffTaker(OffTaker offTaker);

  /// Get all off-takers with optional category filter
  Future<Result<List<OffTaker>>> getAllOffTakers({
    OffTakerCategory? category,
  });

  /// Get off-taker by ID
  Future<Result<OffTaker?>> getOffTakerById(String id);
}
