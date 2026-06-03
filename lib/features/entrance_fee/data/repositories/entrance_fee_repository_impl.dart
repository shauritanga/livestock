import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/entrance_fee/data/datasources/entrance_fee_remote_datasource.dart';
import 'package:livestock/features/entrance_fee/data/models/entrance_fee_model.dart';
import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';
import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';
import 'package:livestock/features/entrance_fee/domain/entities/payment_summary.dart';
import 'package:livestock/features/entrance_fee/domain/repositories/entrance_fee_repository.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';

/// Implementation of entrance fee repository
class EntranceFeeRepositoryImpl implements EntranceFeeRepository {
  final EntranceFeeRemoteDataSource _remoteDataSource;
  final FarmerRepository _farmerRepository;

  EntranceFeeRepositoryImpl({
    required EntranceFeeRemoteDataSource remoteDataSource,
    required FarmerRepository farmerRepository,
  })  : _remoteDataSource = remoteDataSource,
        _farmerRepository = farmerRepository;

  @override
  Future<EntranceFee> recordPayment(EntranceFee fee) async {
    final model = EntranceFeeModel.fromEntity(fee);
    final result = await _remoteDataSource.recordPayment(model);
    return result.toEntity();
  }

  @override
  Future<EntranceFee?> getPaymentByFarmerId(String farmerId) async {
    // Note: We need cooperativeId, but for now we'll handle this in the use case
    throw UnimplementedError('Use getPaymentByFarmerIdAndCooperative instead');
  }

  /// Get payment by farmer ID and cooperative ID
  Future<EntranceFee?> getPaymentByFarmerIdAndCooperative(
    String cooperativeId,
    String farmerId,
  ) async {
    final model = await _remoteDataSource.getPaymentByFarmerId(
      cooperativeId,
      farmerId,
    );
    return model?.toEntity();
  }

  @override
  Stream<List<FarmerPaymentStatus>> getAllFarmersPaymentStatus(
    String cooperativeId,
  ) async* {
    // Get all farmers for the cooperative
    final farmersResult = await _farmerRepository.getFarmersByCooperative(
      cooperativeId,
    );

    final farmers = farmersResult.fold(
      onError: (_) => <Farmer>[],
      onSuccess: (farmers) => farmers,
    );

    if (farmers.isEmpty) {
      yield [];
      return;
    }

    // Stream entrance fee payments
    await for (final payments in _remoteDataSource.getAllPayments(cooperativeId)) {
      // Create a map of farmerId to payment for quick lookup
      final paymentMap = {
        for (var payment in payments) payment.farmerId: payment
      };

      // Combine farmer data with payment status
      final statuses = farmers.map((farmer) {
        final payment = paymentMap[farmer.id];
        return FarmerPaymentStatus(
          farmerId: farmer.id,
          farmerName: farmer.name,
          phoneNumber: farmer.phoneNumber,
          hasPaid: payment != null,
          payment: payment?.toEntity(),
        );
      }).toList();

      yield statuses;
    }
  }

  @override
  Future<PaymentSummary> getPaymentSummary(String cooperativeId) async {
    // Get all farmers
    final farmersResult = await _farmerRepository.getFarmersByCooperative(
      cooperativeId,
    );

    final farmers = farmersResult.fold(
      onError: (_) => <Farmer>[],
      onSuccess: (farmers) => farmers,
    );

    if (farmers.isEmpty) {
      return const PaymentSummary(
        totalFarmers: 0,
        paidCount: 0,
        unpaidCount: 0,
        totalAmountCollected: 0.0,
      );
    }

    final totalFarmers = farmers.length;

    // Get payment count from Firestore
    final payments = await _remoteDataSource.getAllPayments(cooperativeId).first;
    final paidCount = payments.length;
    final unpaidCount = totalFarmers - paidCount;

    // Get total amount collected
    final totalAmount = await _remoteDataSource.getTotalAmountCollected(
      cooperativeId,
    );

    return PaymentSummary(
      totalFarmers: totalFarmers,
      paidCount: paidCount,
      unpaidCount: unpaidCount,
      totalAmountCollected: totalAmount,
    );
  }
}
