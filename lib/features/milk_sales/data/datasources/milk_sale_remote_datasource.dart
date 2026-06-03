import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/milk_sales/data/models/milk_sale_model.dart';

/// Remote data source for milk sale operations with Firestore
class MilkSaleRemoteDataSource {
  final FirebaseFirestore _firestore;

  MilkSaleRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get milk sales collection reference for a cooperative
  CollectionReference _getMilkSalesCollection(String cooperativeId) {
    return _firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('milkSales');
  }

  /// Record a new milk sale
  Future<MilkSaleModel> recordSale(MilkSaleModel sale) async {
    final collection = _getMilkSalesCollection(sale.cooperativeId);
    final docRef = collection.doc();
    
    final saleWithId = MilkSaleModel.fromEntity(
      sale.copyWith(id: docRef.id),
    );
    
    await docRef.set(saleWithId.toJson());
    return saleWithId;
  }

  /// Get all sales for a cooperative
  Future<List<MilkSaleModel>> getSalesByCooperative(String cooperativeId) async {
    final collection = _getMilkSalesCollection(cooperativeId);
    final snapshot = await collection
        .orderBy('saleDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MilkSaleModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get sales filtered by date range
  Future<List<MilkSaleModel>> getSalesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final collection = _getMilkSalesCollection(cooperativeId);
    final snapshot = await collection
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('saleDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MilkSaleModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get sale by ID
  Future<MilkSaleModel?> getSaleById(
    String cooperativeId,
    String saleId,
  ) async {
    final collection = _getMilkSalesCollection(cooperativeId);
    final doc = await collection.doc(saleId).get();

    if (!doc.exists) {
      return null;
    }

    return MilkSaleModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Get sales by off-taker
  Future<List<MilkSaleModel>> getSalesByOffTaker(
    String cooperativeId,
    String offTakerId,
  ) async {
    final collection = _getMilkSalesCollection(cooperativeId);
    final snapshot = await collection
        .where('offTakerId', isEqualTo: offTakerId)
        .orderBy('saleDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MilkSaleModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
