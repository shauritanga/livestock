import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/features/cattle_tracking/data/datasources/cattle_remote_datasource.dart';
import 'package:livestock/features/cattle_tracking/data/repositories/cattle_repository_impl.dart';
import 'package:livestock/features/cattle_tracking/domain/repositories/cattle_repository.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/get_cattle_details.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/get_herd_composition.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/list_farmer_cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/register_cattle.dart';
import 'package:livestock/features/cattle_tracking/domain/usecases/update_cattle.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Provider for cattle remote data source
final cattleRemoteDataSourceProvider = Provider<CattleRemoteDataSource>((ref) {
  return CattleRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Provider for cattle repository
final cattleRepositoryProvider = Provider<CattleRepository>((ref) {
  return CattleRepositoryImpl(
    remoteDataSource: ref.watch(cattleRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Provider for register cattle use case
final registerCattleUseCaseProvider = Provider<RegisterCattle>((ref) {
  return RegisterCattle(ref.watch(cattleRepositoryProvider));
});

/// Provider for get cattle details use case
final getCattleDetailsUseCaseProvider = Provider<GetCattleDetails>((ref) {
  return GetCattleDetails(ref.watch(cattleRepositoryProvider));
});

/// Provider for update cattle use case
final updateCattleUseCaseProvider = Provider<UpdateCattle>((ref) {
  return UpdateCattle(ref.watch(cattleRepositoryProvider));
});

/// Provider for list farmer cattle use case
final listFarmerCattleUseCaseProvider = Provider<ListFarmerCattle>((ref) {
  return ListFarmerCattle(ref.watch(cattleRepositoryProvider));
});

/// Provider for get herd composition use case
final getHerdCompositionUseCaseProvider = Provider<GetHerdComposition>((ref) {
  return GetHerdComposition(ref.watch(cattleRepositoryProvider));
});
