import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';
import 'package:livestock/features/entrance_fee/domain/repositories/entrance_fee_repository.dart';

/// Use case for recording an entrance fee payment
class RecordEntranceFee {
  final EntranceFeeRepository _repository;

  RecordEntranceFee(this._repository);

  /// Execute the use case
  Future<EntranceFee> call(EntranceFee fee) async {
    // Validate the entrance fee
    if (!fee.isValid) {
      throw ArgumentError('Invalid entrance fee: amount must be > 0 and payment date cannot be in the future');
    }

    // Record the payment
    return await _repository.recordPayment(fee);
  }
}
