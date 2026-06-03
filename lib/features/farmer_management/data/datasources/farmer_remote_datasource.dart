import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/features/farmer_management/data/models/farmer_model.dart';

/// Remote data source for farmer operations using Firestore
class FarmerRemoteDataSource {
  final FirebaseFirestore firestore;

  FarmerRemoteDataSource({required this.firestore});

  /// Register a new farmer in Firestore
  Future<FarmerModel> registerFarmer(FarmerModel farmer) async {
    try {
      final docRef = firestore.collection('farmers').doc();

      final farmerWithId = FarmerModel.fromEntity(
        farmer.copyWith(id: docRef.id),
      );

      await docRef.set(farmerWithId.toFirestore());

      return farmerWithId;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to register farmer');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get farmer by ID
  Future<FarmerModel> getFarmerById(String farmerId) async {
    try {
      final doc = await firestore.collection('farmers').doc(farmerId).get();

      if (!doc.exists) {
        throw ServerException('Farmer not found');
      }

      return FarmerModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get farmer');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Update farmer information
  Future<FarmerModel> updateFarmer(FarmerModel farmer) async {
    try {
      await firestore
          .collection('farmers')
          .doc(farmer.id)
          .update(farmer.toFirestore());

      return farmer;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update farmer');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }



  /// Get farmers by cooperative
  Future<List<FarmerModel>> getFarmersByCooperative(
    String cooperativeId, {
    String? searchQuery,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('farmers')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .orderBy('name');

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      var farmers = snapshot.docs
          .map((doc) => FarmerModel.fromFirestore(doc))
          .toList();

      // Apply search filter locally if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        farmers = farmers.where((farmer) {
          return farmer.name.toLowerCase().contains(lowerQuery) ||
              farmer.phoneNumber.contains(searchQuery) ||
              farmer.nationalId.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return farmers;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get farmers');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Delete a farmer
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await firestore.collection('farmers').doc(farmerId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete farmer');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Update cattle counts
  Future<void> updateCattleCounts(
    String farmerId,
    int totalCattle,
    int lactatingCattle,
  ) async {
    try {
      await firestore.collection('farmers').doc(farmerId).update({
        'totalCattle': totalCattle,
        'lactatingCattle': lactatingCattle,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update cattle counts');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Update last delivery date
  Future<void> updateLastDeliveryDate(
    String farmerId,
    DateTime deliveryDate,
  ) async {
    try {
      await firestore.collection('farmers').doc(farmerId).update({
        'lastDeliveryDate': Timestamp.fromDate(deliveryDate),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update last delivery date');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
