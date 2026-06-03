import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/features/cattle_tracking/data/datasources/cattle_remote_datasource.dart';
import 'package:livestock/features/cattle_tracking/data/repositories/cattle_repository_impl.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';
import 'package:livestock/features/insurance/data/datasources/insurance_remote_datasource.dart';
import 'package:livestock/features/insurance/data/repositories/insurance_repository_impl.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';
import 'package:livestock/features/insurance/domain/usecases/usecases.dart';

// ==================== Infrastructure Providers ====================

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Provider for Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for Firebase Storage instance
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Provider for Firestore instance (reused from other features)
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ==================== Data Source Providers ====================

/// Provider for insurance remote data source
final insuranceRemoteDataSourceProvider =
    Provider<InsuranceRemoteDataSource>((ref) {
  return InsuranceRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

/// Provider for cattle remote data source (needed for eligibility verification)
final cattleRemoteDataSourceProvider = Provider<CattleRemoteDataSource>((ref) {
  return CattleRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

// ==================== Repository Providers ====================

/// Provider for insurance repository
/// Note: Requires cooperativeId context
final insuranceRepositoryProvider =
    Provider.family<InsuranceRepository, String>((ref, cooperativeId) {
  return InsuranceRepositoryImpl(
    remoteDataSource: ref.watch(insuranceRemoteDataSourceProvider),
    cooperativeId: cooperativeId,
  );
});

/// Provider for cattle repository (needed for eligibility verification)
final cattleRepositoryProvider = Provider<CattleRepository>((ref) {
  return CattleRepositoryImpl(
    remoteDataSource: ref.watch(cattleRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ==================== Use Case Providers ====================

/// Provider for enroll insurance use case
final enrollInsuranceUseCaseProvider =
    Provider.family<EnrollInsuranceUseCase, String>((ref, cooperativeId) {
  return EnrollInsuranceUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});

/// Provider for calculate premium use case
final calculatePremiumUseCaseProvider =
    Provider.family<CalculatePremiumUseCase, String>((ref, cooperativeId) {
  return CalculatePremiumUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});

/// Provider for get farmer policies use case
final getFarmerPoliciesUseCaseProvider =
    Provider.family<GetFarmerPoliciesUseCase, String>((ref, cooperativeId) {
  return GetFarmerPoliciesUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});

/// Provider for get policy details use case
final getPolicyDetailsUseCaseProvider =
    Provider.family<GetPolicyDetailsUseCase, String>((ref, cooperativeId) {
  return GetPolicyDetailsUseCase(
    insuranceRepository: ref.watch(insuranceRepositoryProvider(cooperativeId)),
    cattleRepository: ref.watch(cattleRepositoryProvider),
  );
});

/// Provider for submit claim use case
final submitClaimUseCaseProvider =
    Provider.family<SubmitClaimUseCase, String>((ref, cooperativeId) {
  return SubmitClaimUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});

/// Provider for get farmer claims use case
final getFarmerClaimsUseCaseProvider =
    Provider.family<GetFarmerClaimsUseCase, String>((ref, cooperativeId) {
  return GetFarmerClaimsUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});

/// Provider for verify insurance eligibility use case
final verifyInsuranceEligibilityUseCaseProvider =
    Provider.family<VerifyInsuranceEligibilityUseCase, String>(
        (ref, cooperativeId) {
  return VerifyInsuranceEligibilityUseCase(
    insuranceRepository: ref.watch(insuranceRepositoryProvider(cooperativeId)),
    cattleRepository: ref.watch(cattleRepositoryProvider),
  );
});

/// Provider for record premium payment use case
final recordPremiumPaymentUseCaseProvider =
    Provider.family<RecordPremiumPaymentUseCase, String>((ref, cooperativeId) {
  return RecordPremiumPaymentUseCase(
    ref.watch(insuranceRepositoryProvider(cooperativeId)),
  );
});
