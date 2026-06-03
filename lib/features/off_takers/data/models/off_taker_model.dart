import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_status.dart';

/// Off-taker data model (MVP - simplified)
class OffTakerModel extends OffTaker {
  const OffTakerModel({
    required super.id,
    required super.cooperativeId,
    required super.businessName,
    required super.contactPerson,
    required super.phoneNumber,
    required super.category,
    required super.status,
    required super.registeredAt,
  });

  /// Create model from JSON
  factory OffTakerModel.fromJson(Map<String, dynamic> json) {
    return OffTakerModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      businessName: json['businessName'] as String,
      contactPerson: json['contactPerson'] as String,
      phoneNumber: json['phoneNumber'] as String,
      category: OffTakerCategory.fromString(json['category'] as String),
      status: OffTakerStatus.fromString(json['status'] as String),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'businessName': businessName,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'category': category.name,
      'status': status.name,
      'registeredAt': Timestamp.fromDate(registeredAt),
    };
  }

  /// Create model from entity
  factory OffTakerModel.fromEntity(OffTaker entity) {
    return OffTakerModel(
      id: entity.id,
      cooperativeId: entity.cooperativeId,
      businessName: entity.businessName,
      contactPerson: entity.contactPerson,
      phoneNumber: entity.phoneNumber,
      category: entity.category,
      status: entity.status,
      registeredAt: entity.registeredAt,
    );
  }

  /// Convert model to entity
  OffTaker toEntity() {
    return OffTaker(
      id: id,
      cooperativeId: cooperativeId,
      businessName: businessName,
      contactPerson: contactPerson,
      phoneNumber: phoneNumber,
      category: category,
      status: status,
      registeredAt: registeredAt,
    );
  }
}
