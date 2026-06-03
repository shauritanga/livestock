import 'package:livestock/core/utils/result.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/repositories/off_taker_repository.dart';

/// Use case for creating a new off-taker (MVP - basic validation only)
class CreateOffTaker {
  final OffTakerRepository repository;

  CreateOffTaker(this.repository);

  Future<Result<OffTaker>> call(OffTaker offTaker) async {
    // Validate required fields only
    if (offTaker.businessName.trim().isEmpty) {
      return Error(ValidationFailure('Business name is required'));
    }

    if (offTaker.contactPerson.trim().isEmpty) {
      return Error(ValidationFailure('Contact person is required'));
    }

    if (offTaker.phoneNumber.trim().isEmpty) {
      return Error(ValidationFailure('Phone number is required'));
    }

    return repository.createOffTaker(offTaker);
  }
}
