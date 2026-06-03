import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:livestock/core/constants/firebase_constants.dart';
import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/features/cattle_tracking/data/models/cattle_model.dart';
import 'package:livestock/features/insurance/data/models/models.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';

/// Remote data source for insurance operations using Firestore and Firebase Storage
class InsuranceRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  InsuranceRemoteDataSource({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  // ==================== Policy Management ====================

  /// Create a new insurance policy in Firestore
  Future<InsurancePolicyModel> createPolicy({
    required String farmerId,
    required String cooperativeId,
    required List<String> cattleIds,
    required double totalPremium,
    required PaymentFrequency paymentFrequency,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      final docRef = firestore.collection('insurancePolicies').doc();

      final now = DateTime.now();
      final policyEndDate = DateTime(
        now.year + 1,
        now.month,
        now.day,
      );

      final installmentAmount = paymentFrequency == PaymentFrequency.monthly
          ? totalPremium / 12
          : totalPremium / 4;

      final nextPaymentDue = paymentFrequency == PaymentFrequency.monthly
          ? DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year, now.month + 3, now.day);

      final policy = InsurancePolicyModel(
        id: docRef.id,
        farmerId: farmerId,
        cooperativeId: cooperativeId,
        insurancePartnerId: 'default_partner',
        coveredCattleIds: cattleIds,
        totalPremium: totalPremium,
        installmentAmount: installmentAmount,
        paymentFrequency: paymentFrequency,
        policyStartDate: now,
        policyEndDate: policyEndDate,
        status: PolicyStatus.active,
        nextPaymentDue: nextPaymentDue,
        totalPaid: 0,
        outstandingPremium: totalPremium,
        createdAt: now,
        updatedAt: now,
        createdBy: user.uid,
      );

      await docRef.set(policy.toFirestore());

      return policy;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create policy');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get a specific insurance policy by ID
  Future<InsurancePolicyModel> getPolicy(String policyId) async {
    try {
      final doc =
          await firestore.collection('insurancePolicies').doc(policyId).get();

      if (!doc.exists) {
        throw const NotFoundException('Policy not found');
      }

      return InsurancePolicyModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get policy');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get all insurance policies for a farmer
  Future<List<InsurancePolicyModel>> getFarmerPolicies(
    String farmerId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('insurancePolicies')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InsurancePolicyModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get farmer policies');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Update policy status
  Future<InsurancePolicyModel> updatePolicyStatus(
    String policyId,
    PolicyStatus status,
  ) async {
    try {
      final docRef = firestore.collection('insurancePolicies').doc(policyId);

      await docRef.update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final doc = await docRef.get();
      return InsurancePolicyModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update policy status');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Premium Calculation ====================

  /// Calculate insurance premium for selected cattle
  Future<PremiumCalculation> calculatePremium({
    required List<String> cattleIds,
  }) async {
    try {
      // Fetch cattle details
      final cattleModels = await Future.wait(
        cattleIds.map((cattleId) async {
          final doc = await firestore.collection('cattle').doc(cattleId).get();

          if (!doc.exists) {
            throw NotFoundException('Cattle $cattleId not found');
          }

          return CattleModel.fromFirestore(doc);
        }),
      );

      // Fetch active premium rates
      final ratesSnapshot = await firestore
          .collection(FirebaseConstants.premiumRatesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final rates = ratesSnapshot.docs
          .map((doc) => PremiumRateModel.fromFirestore(doc))
          .toList();

      // Calculate premium for each cattle
      final cattlePremiums = cattleModels.map((cattle) {
        final rate = _findMatchingRate(cattle, rates);
        return CattlePremium(
          cattleId: cattle.id,
          cattleName: cattle.id,
          premium: rate.baseRate,
          rateCategory: '${cattle.breed}-${cattle.ageMonths}months',
        );
      }).toList();

      final totalAnnualPremium =
          cattlePremiums.fold(0.0, (sum, cp) => sum + cp.premium);

      return PremiumCalculation(
        cattlePremiums: cattlePremiums,
        totalAnnualPremium: totalAnnualPremium,
        monthlyInstallment: totalAnnualPremium / 12,
        quarterlyInstallment: totalAnnualPremium / 4,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to calculate premium');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Find matching premium rate for a cattle
  PremiumRateModel _findMatchingRate(
    CattleModel cattle,
    List<PremiumRateModel> rates,
  ) {
    // Try to find exact match
    final matchingRate = rates.where((rate) {
      final ageMatch =
          cattle.ageMonths >= rate.minAge && cattle.ageMonths <= rate.maxAge;
      final breedMatch = _getBreedCategory(cattle.breed) == rate.breedCategory;
      return ageMatch && breedMatch;
    }).firstOrNull;

    // Return matching rate or default
    return matchingRate ??
        PremiumRateModel(
          id: 'default',
          minAge: 0,
          maxAge: 999,
          breedCategory: 'default',
          healthStatus: 'healthy',
          baseRate: 5000.0,
          effectiveDate: DateTime.now(),
          isActive: true,
        );
  }

  /// Get breed category from breed name
  String _getBreedCategory(String breed) {
    final breedLower = breed.toLowerCase();
    if (breedLower.contains('friesian') ||
        breedLower.contains('jersey') ||
        breedLower.contains('ayrshire')) {
      return 'exotic';
    } else if (breedLower.contains('cross')) {
      return 'crossbreed';
    } else {
      return 'local';
    }
  }

  // ==================== Premium Payments ====================

  /// Record a premium payment
  Future<void> recordPremiumPayment({
    required String policyId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      final policyRef = firestore.collection('insurancePolicies').doc(policyId);

      // Get current policy
      final policyDoc = await policyRef.get();
      if (!policyDoc.exists) {
        throw const NotFoundException('Policy not found');
      }

      final policy = InsurancePolicyModel.fromFirestore(policyDoc);

      // Create payment record
      final paymentRef = policyRef.collection('premiumPayments').doc();
      final payment = PremiumPaymentModel(
        id: paymentRef.id,
        policyId: policyId,
        amount: amount,
        paymentDate: DateTime.now(),
        paymentMethod: paymentMethod,
        milkDeliveryId: milkDeliveryId,
        recordedBy: user.uid,
      );

      await paymentRef.set(payment.toFirestore());

      // Update policy
      final nextPaymentDue = policy.paymentFrequency == PaymentFrequency.monthly
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 90));

      await policyRef.update({
        'totalPaid': FieldValue.increment(amount),
        'outstandingPremium': FieldValue.increment(-amount),
        'nextPaymentDue': Timestamp.fromDate(nextPaymentDue),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to record payment');
    } catch (e) {
      if (e is AuthenticationException || e is NotFoundException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get premium payments for a policy
  Future<List<PremiumPaymentModel>> getPolicyPayments(String policyId) async {
    try {
      final snapshot = await firestore
          .collection('insurancePolicies')
          .doc(policyId)
          .collection('premiumPayments')
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PremiumPaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get policy payments');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Claims Management ====================

  /// Create a new insurance claim
  Future<InsuranceClaimModel> createClaim({
    required String policyId,
    required String farmerId,
    required String cattleId,
    required LossType lossType,
    required DateTime lossDate,
    required String description,
    required List<String> supportingDocuments,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      final docRef = firestore
          .collection('insurancePolicies')
          .doc(policyId)
          .collection('claims')
          .doc();

      final now = DateTime.now();
      final claim = InsuranceClaimModel(
        id: docRef.id,
        policyId: policyId,
        cattleId: cattleId,
        farmerId: farmerId,
        lossType: lossType,
        lossDate: lossDate,
        description: description,
        claimAmount: 50000.0, // TODO: Calculate based on cattle value
        submittedDate: now,
        status: ClaimStatus.submitted,
        statusUpdates: [
          ClaimStatusUpdate(
            status: ClaimStatus.submitted,
            date: now,
            comment: 'Claim submitted',
          ),
        ],
        supportingDocuments: supportingDocuments,
        submittedBy: user.uid,
      );

      await docRef.set(claim.toFirestore());

      return claim;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create claim');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get a specific claim by ID
  Future<InsuranceClaimModel> getClaim(
    String claimId,
    String policyId,
  ) async {
    try {
      final doc = await firestore
          .collection('insurancePolicies')
          .doc(policyId)
          .collection('claims')
          .doc(claimId)
          .get();

      if (!doc.exists) {
        throw const NotFoundException('Claim not found');
      }

      return InsuranceClaimModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get claim');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get all claims for a farmer
  Future<List<InsuranceClaimModel>> getFarmerClaims(String farmerId) async {
    try {
      // Get all policies for the farmer
      final policiesSnapshot = await firestore
          .collection('insurancePolicies')
          .where('farmerId', isEqualTo: farmerId)
          .get();

      // Get claims from all policies
      final allClaims = <InsuranceClaimModel>[];
      for (final policyDoc in policiesSnapshot.docs) {
        final claimsSnapshot =
            await policyDoc.reference.collection('claims').get();

        final claims = claimsSnapshot.docs
            .map((doc) => InsuranceClaimModel.fromFirestore(doc))
            .toList();

        allClaims.addAll(claims);
      }

      // Sort by submission date (most recent first)
      allClaims.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));

      return allClaims;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get farmer claims');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get all claims for a specific policy
  Future<List<InsuranceClaimModel>> getPolicyClaims(String policyId) async {
    try {
      final snapshot = await firestore
          .collection('insurancePolicies')
          .doc(policyId)
          .collection('claims')
          .orderBy('submittedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InsuranceClaimModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get policy claims');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Document Management ====================

  /// Upload a document to Firebase Storage
  Future<String> uploadDocument(File document, String farmerId) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${document.path.split('/').last}';
      final ref = storage.ref().child('insurance_documents/$farmerId/$fileName');

      final uploadTask = await ref.putFile(document);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to upload document');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Premium Rates ====================

  /// Get all active premium rates
  Future<List<PremiumRateModel>> getPremiumRates() async {
    try {
      final snapshot = await firestore
          .collection('premiumRates')
          .where('isActive', isEqualTo: true)
          .orderBy('effectiveDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PremiumRateModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get premium rates');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}

/// Extension to get first element or null
extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
