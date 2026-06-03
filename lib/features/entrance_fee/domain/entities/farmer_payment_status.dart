import 'package:equatable/equatable.dart';
import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';

/// Entity combining farmer information with entrance fee payment status
class FarmerPaymentStatus extends Equatable {
  final String farmerId;
  final String farmerName;
  final String phoneNumber;
  final bool hasPaid;
  final EntranceFee? payment;

  const FarmerPaymentStatus({
    required this.farmerId,
    required this.farmerName,
    required this.phoneNumber,
    required this.hasPaid,
    this.payment,
  });

  @override
  List<Object?> get props => [
        farmerId,
        farmerName,
        phoneNumber,
        hasPaid,
        payment,
      ];
}
