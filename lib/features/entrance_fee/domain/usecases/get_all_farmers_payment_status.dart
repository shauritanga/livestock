import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';
import 'package:livestock/features/entrance_fee/domain/repositories/entrance_fee_repository.dart';

/// Use case for getting payment status for all farmers
class GetAllFarmersPaymentStatus {
  final EntranceFeeRepository _repository;

  GetAllFarmersPaymentStatus(this._repository);

  /// Execute the use case
  Stream<List<FarmerPaymentStatus>> call(String cooperativeId) {
    return _repository.getAllFarmersPaymentStatus(cooperativeId);
  }
}
