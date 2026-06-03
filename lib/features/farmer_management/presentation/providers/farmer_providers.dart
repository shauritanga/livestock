import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/data/datasources/farmer_remote_datasource.dart';
import 'package:livestock/features/farmer_management/data/repositories/farmer_repository_impl.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';
import 'package:livestock/features/farmer_management/domain/usecases/get_farmer_details.dart';
import 'package:livestock/features/farmer_management/domain/usecases/list_farmers.dart';
import 'package:livestock/features/farmer_management/domain/usecases/register_farmer.dart';
import 'package:livestock/features/farmer_management/domain/usecases/update_farmer.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Provider for farmer remote data source
final farmerRemoteDataSourceProvider = Provider<FarmerRemoteDataSource>((ref) {
  return FarmerRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Provider for farmer repository
final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  return FarmerRepositoryImpl(
    remoteDataSource: ref.watch(farmerRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Provider for register farmer use case
final registerFarmerUseCaseProvider = Provider<RegisterFarmer>((ref) {
  return RegisterFarmer(ref.watch(farmerRepositoryProvider));
});

/// Provider for get farmer details use case
final getFarmerDetailsUseCaseProvider = Provider<GetFarmerDetails>((ref) {
  return GetFarmerDetails(ref.watch(farmerRepositoryProvider));
});

/// Provider for update farmer use case
final updateFarmerUseCaseProvider = Provider<UpdateFarmer>((ref) {
  return UpdateFarmer(ref.watch(farmerRepositoryProvider));
});

/// Provider for list farmers use case
final listFarmersUseCaseProvider = Provider<ListFarmers>((ref) {
  return ListFarmers(ref.watch(farmerRepositoryProvider));
});

/// Provider for getting a farmer by ID
final farmerByIdProvider = FutureProvider.family((ref, String farmerId) async {
  final useCase = ref.watch(getFarmerDetailsUseCaseProvider);
  final result = await useCase(farmerId);
  
  return result.fold(
    onError: (failure) => null,
    onSuccess: (farmer) => farmer,
  );
});
