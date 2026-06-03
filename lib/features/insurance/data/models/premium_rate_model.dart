import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Premium rate model for Firestore serialization
class PremiumRateModel extends PremiumRate {
  const PremiumRateModel({
    required super.id,
    required super.minAge,
    required super.maxAge,
    required super.breedCategory,
    required super.healthStatus,
    required super.baseRate,
    required super.effectiveDate,
    required super.isActive,
  });

  /// Convert Firestore document to PremiumRateModel
  factory PremiumRateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse age range
    final ageRange = data['cattleAgeRange'] as Map<String, dynamic>;
    
    return PremiumRateModel(
      id: doc.id,
      minAge: ageRange['min'] as int,
      maxAge: ageRange['max'] as int,
      breedCategory: data['breedCategory'] as String,
      healthStatus: data['healthStatus'] as String,
      baseRate: (data['baseRate'] as num).toDouble(),
      effectiveDate: (data['effectiveDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Convert PremiumRateModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'cattleAgeRange': {
        'min': minAge,
        'max': maxAge,
      },
      'breedCategory': breedCategory,
      'healthStatus': healthStatus,
      'baseRate': baseRate,
      'effectiveDate': Timestamp.fromDate(effectiveDate),
      'isActive': isActive,
    };
  }

  /// Convert PremiumRate to PremiumRateModel
  factory PremiumRateModel.fromEntity(PremiumRate rate) {
    return PremiumRateModel(
      id: rate.id,
      minAge: rate.minAge,
      maxAge: rate.maxAge,
      breedCategory: rate.breedCategory,
      healthStatus: rate.healthStatus,
      baseRate: rate.baseRate,
      effectiveDate: rate.effectiveDate,
      isActive: rate.isActive,
    );
  }

  /// Convert PremiumRateModel to PremiumRate entity
  PremiumRate toEntity() {
    return PremiumRate(
      id: id,
      minAge: minAge,
      maxAge: maxAge,
      breedCategory: breedCategory,
      healthStatus: healthStatus,
      baseRate: baseRate,
      effectiveDate: effectiveDate,
      isActive: isActive,
    );
  }
}
