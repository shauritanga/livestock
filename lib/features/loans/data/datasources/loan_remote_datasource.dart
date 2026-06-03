import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/loan_repayment_model.dart';

/// Remote data source for loan operations using Firestore
class LoanRemoteDataSource {
  final FirebaseFirestore firestore;

  LoanRemoteDataSource({required this.firestore});

  /// Create a new loan application
  Future<LoanModel> createLoan(LoanModel loan) async {
    final docRef = await firestore
        .collection('cooperatives')
        .doc(loan.cooperativeId)
        .collection('collectionCentres')
        .doc('default') // TODO: Get actual collection centre ID
        .collection('farmers')
        .doc(loan.farmerId)
        .collection('loans')
        .add(loan.toFirestore());

    final doc = await docRef.get();
    return LoanModel.fromFirestore(doc);
  }

  /// Get loan by ID
  Future<LoanModel> getLoanById(
    String cooperativeId,
    String farmerId,
    String loanId,
  ) async {
    final doc = await firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .doc(loanId)
        .get();

    if (!doc.exists) {
      throw Exception('Loan not found');
    }

    return LoanModel.fromFirestore(doc);
  }

  /// Get all loans for a farmer
  Future<List<LoanModel>> getFarmerLoans(
    String cooperativeId,
    String farmerId,
  ) async {
    final querySnapshot = await firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => LoanModel.fromFirestore(doc)).toList();
  }

  /// Get all loans for a cooperative
  Future<List<LoanModel>> getCooperativeLoans(String cooperativeId) async {
    // This requires a collection group query
    final querySnapshot = await firestore
        .collectionGroup('loans')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => LoanModel.fromFirestore(doc)).toList();
  }

  /// Get pending loan applications
  Future<List<LoanModel>> getPendingLoans(String cooperativeId) async {
    final querySnapshot = await firestore
        .collectionGroup('loans')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => LoanModel.fromFirestore(doc)).toList();
  }

  /// Update loan
  Future<LoanModel> updateLoan(
    String cooperativeId,
    String farmerId,
    String loanId,
    Map<String, dynamic> updates,
  ) async {
    final docRef = firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .doc(loanId);

    await docRef.update(updates);
    final doc = await docRef.get();
    return LoanModel.fromFirestore(doc);
  }

  /// Create loan repayment
  Future<LoanRepaymentModel> createRepayment(
    String cooperativeId,
    String farmerId,
    String loanId,
    LoanRepaymentModel repayment,
  ) async {
    final docRef = await firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .doc(loanId)
        .collection('repayments')
        .add(repayment.toFirestore());

    final doc = await docRef.get();
    return LoanRepaymentModel.fromFirestore(doc);
  }

  /// Get loan repayments
  Future<List<LoanRepaymentModel>> getLoanRepayments(
    String cooperativeId,
    String farmerId,
    String loanId,
  ) async {
    final querySnapshot = await firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .doc(loanId)
        .collection('repayments')
        .orderBy('paymentDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LoanRepaymentModel.fromFirestore(doc))
        .toList();
  }

  /// Stream farmer loans
  Stream<List<LoanModel>> watchFarmerLoans(
    String cooperativeId,
    String farmerId,
  ) {
    return firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc('default')
        .collection('farmers')
        .doc(farmerId)
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LoanModel.fromFirestore(doc)).toList());
  }

  /// Stream cooperative loans
  Stream<List<LoanModel>> watchCooperativeLoans(String cooperativeId) {
    return firestore
        .collectionGroup('loans')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LoanModel.fromFirestore(doc)).toList());
  }
}
