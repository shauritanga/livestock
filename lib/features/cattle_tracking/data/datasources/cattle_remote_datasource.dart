import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/features/cattle_tracking/data/models/cattle_model.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';

/// Remote data source for cattle operations using Firestore
class CattleRemoteDataSource {
  final FirebaseFirestore firestore;

  CattleRemoteDataSource({required this.firestore});

  /// Register a new cattle in Firestore
  Future<CattleModel> registerCattle(CattleModel cattle) async {
    try {
      final docRef = firestore.collection('cattle').doc();

      final cattleWithId = CattleModel.fromEntity(
        cattle.copyWith(id: docRef.id),
      );

      await docRef.set(cattleWithId.toFirestore());

      return cattleWithId;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to register cattle');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get cattle by ID
  Future<CattleModel> getCattleById(String cattleId) async {
    try {
      final doc = await firestore.collection('cattle').doc(cattleId).get();

      if (!doc.exists) {
        throw ServerException('Cattle not found');
      }

      return CattleModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get cattle');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Update cattle information
  Future<CattleModel> updateCattle(CattleModel cattle) async {
    try {
      await firestore
          .collection('cattle')
          .doc(cattle.id)
          .update(cattle.toFirestore());

      return cattle;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update cattle');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get cattle by farmer
  Future<List<CattleModel>> getCattleByFarmer(String farmerId) async {
    try {
      final snapshot = await firestore
          .collection('cattle')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('acquisitionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CattleModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get cattle');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }



  /// Get cattle by cooperative
  Future<List<CattleModel>> getCattleByCooperative(
    String cooperativeId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('cattle')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .orderBy('acquisitionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CattleModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get cattle');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Delete a cattle
  Future<void> deleteCattle(String cattleId) async {
    try {
      await firestore.collection('cattle').doc(cattleId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete cattle');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get herd composition for a farmer
  Future<Map<String, int>> getHerdComposition(String farmerId) async {
    try {
      final cattle = await getCattleByFarmer(farmerId);

      final composition = <String, int>{
        'total': cattle.length,
        'lactating': 0,
        'dry': 0,
        'pregnant': 0,
        'calves': 0,
        'male': 0,
        'female': 0,
      };

      for (final animal in cattle) {
        // Count by lactation status
        switch (animal.lactationStatus) {
          case LactationStatus.lactating:
            composition['lactating'] = composition['lactating']! + 1;
            break;
          case LactationStatus.dry:
            composition['dry'] = composition['dry']! + 1;
            break;
          case LactationStatus.pregnant:
            composition['pregnant'] = composition['pregnant']! + 1;
            break;
          case LactationStatus.calf:
            composition['calves'] = composition['calves']! + 1;
            break;
        }

        // Count by gender
        if (animal.gender == CattleGender.male) {
          composition['male'] = composition['male']! + 1;
        } else {
          composition['female'] = composition['female']! + 1;
        }
      }

      return composition;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get herd composition');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }
}
