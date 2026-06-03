import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/entrance_fee/data/models/entrance_fee_model.dart';

/// Remote data source for entrance fee operations with Firestore
class EntranceFeeRemoteDataSource {
  final FirebaseFirestore _firestore;

  EntranceFeeRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get entrance fees collection reference for a cooperative
  CollectionReference _getEntranceFeesCollection(String cooperativeId) {
    return _firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('entranceFees');
  }

  /// Record a new entrance fee payment
  Future<EntranceFeeModel> recordPayment(EntranceFeeModel fee) async {
    final collection = _getEntranceFeesCollection(fee.cooperativeId);
    
    // Use farmerId as document ID to ensure uniqueness
    await collection.doc(fee.farmerId).set(fee.toJson());
    
    return fee;
  }

  /// Get payment record for a specific farmer
  Future<EntranceFeeModel?> getPaymentByFarmerId(
    String cooperativeId,
    String farmerId,
  ) async {
    final collection = _getEntranceFeesCollection(cooperativeId);
    final doc = await collection.doc(farmerId).get();

    if (!doc.exists) {
      return null;
    }

    return EntranceFeeModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Get all entrance fee payments for a cooperative
  Stream<List<EntranceFeeModel>> getAllPayments(String cooperativeId) {
    final collection = _getEntranceFeesCollection(cooperativeId);
    
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EntranceFeeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get total amount collected from entrance fees
  Future<double> getTotalAmountCollected(String cooperativeId) async {
    final collection = _getEntranceFeesCollection(cooperativeId);
    final snapshot = await collection.get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] as num).toDouble();
    }

    return total;
  }
}
