import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/constants/firebase_constants.dart';
import 'package:livestock/features/off_takers/data/models/off_taker_model.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';

/// Remote data source interface for off-takers (MVP)
abstract class OffTakerRemoteDataSource {
  Future<OffTakerModel> createOffTaker(OffTakerModel offTaker);
  Future<List<OffTakerModel>> getAllOffTakers(
    String cooperativeId, {
    OffTakerCategory? category,
  });
  Future<OffTakerModel?> getOffTakerById(String id);
}

/// Implementation of off-taker remote data source using Firestore (MVP)
class OffTakerRemoteDataSourceImpl implements OffTakerRemoteDataSource {
  final FirebaseFirestore firestore;

  OffTakerRemoteDataSourceImpl({required this.firestore});

  @override
  Future<OffTakerModel> createOffTaker(OffTakerModel offTaker) async {
    try {
      final docRef = firestore
          .collection(FirebaseConstants.offtakersCollection)
          .doc(offTaker.id);

      await docRef.set(offTaker.toJson());

      return offTaker;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create off-taker: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create off-taker: $e');
    }
  }

  @override
  Future<List<OffTakerModel>> getAllOffTakers(
    String cooperativeId, {
    OffTakerCategory? category,
  }) async {
    try {
      Query query = firestore
          .collection(FirebaseConstants.offtakersCollection)
          .where('cooperativeId', isEqualTo: cooperativeId);

      // Apply category filter if provided
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => OffTakerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get off-takers: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get off-takers: $e');
    }
  }

  @override
  Future<OffTakerModel?> getOffTakerById(String id) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.offtakersCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        return null;
      }

      return OffTakerModel.fromJson(doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get off-taker: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get off-taker: $e');
    }
  }
}
