import 'package:equatable/equatable.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_status.dart';

/// Off-taker entity representing a bulk buyer (MVP - simplified)
class OffTaker extends Equatable {
  final String id;
  final String cooperativeId;
  final String businessName;
  final String contactPerson;
  final String phoneNumber;
  final OffTakerCategory category;
  final OffTakerStatus status;
  final DateTime registeredAt;

  const OffTaker({
    required this.id,
    required this.cooperativeId,
    required this.businessName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.category,
    required this.status,
    required this.registeredAt,
  });

  /// Check if off-taker is active
  bool get isActive => status == OffTakerStatus.active;

  /// Copy with method for creating modified copies
  OffTaker copyWith({
    String? id,
    String? cooperativeId,
    String? businessName,
    String? contactPerson,
    String? phoneNumber,
    OffTakerCategory? category,
    OffTakerStatus? status,
    DateTime? registeredAt,
  }) {
    return OffTaker(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      businessName: businessName ?? this.businessName,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        businessName,
        contactPerson,
        phoneNumber,
        category,
        status,
        registeredAt,
      ];
}
