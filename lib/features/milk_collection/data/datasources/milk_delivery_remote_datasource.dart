import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/features/milk_collection/data/models/milk_delivery_model.dart';

/// Remote data source for milk delivery operations using Firestore
class MilkDeliveryRemoteDataSource {
  final FirebaseFirestore firestore;

  MilkDeliveryRemoteDataSource({required this.firestore});

  /// Record a new milk delivery in Firestore
  Future<MilkDeliveryModel> recordDelivery(MilkDeliveryModel delivery) async {
    try {
      final docRef = firestore.collection('milkDeliveries').doc();

      final deliveryWithId = MilkDeliveryModel.fromEntity(
        delivery.copyWith(id: docRef.id),
      );

      await docRef.set(deliveryWithId.toFirestore());

      // Update farmer's last delivery date
      await firestore.collection('farmers').doc(delivery.farmerId).update({
        'lastDeliveryDate': Timestamp.fromDate(delivery.deliveryDate),
      });

      return deliveryWithId;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to record delivery');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get delivery history for a farmer
  Future<List<MilkDeliveryModel>> getDeliveryHistory(
    String farmerId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('milkDeliveries')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('deliveryDate', descending: true);

      if (startDate != null) {
        query = query.where('deliveryDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('deliveryDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MilkDeliveryModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get delivery history');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get today's deliveries for a cooperative
  Future<List<MilkDeliveryModel>> getTodaysDeliveries(
    String cooperativeId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getDeliveriesByCooperative(
        cooperativeId,
        startOfDay,
        endOfDay,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get today\'s deliveries');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get deliveries by date range for a cooperative (deprecated - use getDeliveriesByCooperative)
  @Deprecated('Use getDeliveriesByCooperative instead')
  Future<List<MilkDeliveryModel>> getDeliveriesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return getDeliveriesByCooperative(cooperativeId, startDate, endDate);
  }

  /// Get deliveries by cooperative and date range
  Future<List<MilkDeliveryModel>> getDeliveriesByCooperative(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate, {
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('milkDeliveries')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .where('deliveryDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('deliveryDate', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('deliveryDate', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MilkDeliveryModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to get deliveries by cooperative');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Calculate payment based on quantity
  /// Uses the farmer payment price from cooperative (dual pricing model)
  Future<double> calculatePayment(
    double quantity,
    String qualityGrade, // Kept for compatibility but not used
    String cooperativeId,
  ) async {
    try {
      // Get cooperative pricing
      final cooperativeDoc =
          await firestore.collection('cooperatives').doc(cooperativeId).get();

      if (!cooperativeDoc.exists) {
        throw ServerException('Cooperative not found');
      }

      final data = cooperativeDoc.data()!;
      // Farmer payment price in TZS per liter
      // Default: 1200 TZS (matches seed data - offtaker pays 1500 TZS, cooperative keeps 300 TZS margin)
      final farmerPricePerLiter = (data['farmerPaymentPrice'] as num?)?.toDouble() ?? 1200.0;

      // Simple calculation: quantity × farmer price
      final totalAmount = quantity * farmerPricePerLiter;

      return totalAmount;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to calculate payment');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Stream deliveries for a cooperative (for real-time inventory)
  Stream<List<MilkDeliveryModel>> streamDeliveriesByCooperative(String cooperativeId) {
    try {
      return firestore
          .collection('milkDeliveries')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .orderBy('deliveryDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MilkDeliveryModel.fromFirestore(doc))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to stream deliveries');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
