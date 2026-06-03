import 'package:livestock/features/entrance_fee/domain/entities/payment_summary.dart';
import 'package:livestock/features/entrance_fee/domain/repositories/entrance_fee_repository.dart';

/// Use case for getting entrance fee payment summary
class GetPaymentSummary {
  final EntranceFeeRepository _repository;

  GetPaymentSummary(this._repository);

  /// Execute the use case
  Future<PaymentSummary> call(String cooperativeId) async {
    return await _repository.getPaymentSummary(cooperativeId);
  }
}
