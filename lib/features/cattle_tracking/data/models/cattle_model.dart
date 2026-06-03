import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';

/// Cattle model for Firestore serialization
class CattleModel extends Cattle {
  const CattleModel({
    required super.id,
    required super.farmerId,
    required super.cooperativeId,
    required super.gender,
    required super.ageMonths,
    required super.breed,
    required super.lactationStatus,
    required super.healthStatus,
    required super.acquisitionDate,
    super.biometricId,
    super.muzzleImageUrl,
    super.lastProductionDate,
    required super.averageDailyProduction,
    super.lastStatusChangeDate,
  });

  /// Convert Firestore document to CattleModel
  factory CattleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CattleModel(
      id: doc.id,
      farmerId: data['farmerId'] as String,
      cooperativeId: data['cooperativeId'] as String,
      gender: CattleGender.values.firstWhere(
        (e) => e.name == data['gender'],
        orElse: () => CattleGender.female,
      ),
      ageMonths: data['ageMonths'] as int,
      breed: data['breed'] as String,
      lactationStatus: LactationStatus.values.firstWhere(
        (e) => e.name == data['lactationStatus'],
        orElse: () => LactationStatus.dry,
      ),
      healthStatus: data['healthStatus'] as String,
      acquisitionDate: (data['acquisitionDate'] as Timestamp).toDate(),
      biometricId: data['biometricId'] as String?,
      muzzleImageUrl: data['muzzleImageUrl'] as String?,
      lastProductionDate: data['lastProductionDate'] != null
          ? (data['lastProductionDate'] as Timestamp).toDate()
          : null,
      averageDailyProduction:
          (data['averageDailyProduction'] as num?)?.toDouble() ?? 0.0,
      lastStatusChangeDate: data['lastStatusChangeDate'] != null
          ? (data['lastStatusChangeDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert CattleModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'farmerId': farmerId,
      'cooperativeId': cooperativeId,
      'gender': gender.name,
      'ageMonths': ageMonths,
      'breed': breed,
      'lactationStatus': lactationStatus.name,
      'healthStatus': healthStatus,
      'acquisitionDate': Timestamp.fromDate(acquisitionDate),
      'biometricId': biometricId,
      'muzzleImageUrl': muzzleImageUrl,
      'lastProductionDate': lastProductionDate != null
          ? Timestamp.fromDate(lastProductionDate!)
          : null,
      'averageDailyProduction': averageDailyProduction,
      'lastStatusChangeDate': lastStatusChangeDate != null
          ? Timestamp.fromDate(lastStatusChangeDate!)
          : null,
    };
  }

  /// Convert Cattle entity to CattleModel
  factory CattleModel.fromEntity(Cattle cattle) {
    return CattleModel(
      id: cattle.id,
      farmerId: cattle.farmerId,
      cooperativeId: cattle.cooperativeId,
      gender: cattle.gender,
      ageMonths: cattle.ageMonths,
      breed: cattle.breed,
      lactationStatus: cattle.lactationStatus,
      healthStatus: cattle.healthStatus,
      acquisitionDate: cattle.acquisitionDate,
      biometricId: cattle.biometricId,
      muzzleImageUrl: cattle.muzzleImageUrl,
      lastProductionDate: cattle.lastProductionDate,
      averageDailyProduction: cattle.averageDailyProduction,
      lastStatusChangeDate: cattle.lastStatusChangeDate,
    );
  }
}
