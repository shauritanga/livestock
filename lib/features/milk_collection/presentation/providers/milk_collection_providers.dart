import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/features/milk_collection/data/datasources/milk_delivery_remote_datasource.dart';
import 'package:livestock/features/milk_collection/data/repositories/milk_delivery_repository_impl.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';
import 'package:livestock/features/milk_collection/domain/usecases/calculate_payment.dart';
import 'package:livestock/features/milk_collection/domain/usecases/get_deliveries_by_collection_centre.dart';
import 'package:livestock/features/milk_collection/domain/usecases/get_delivery_history.dart';
import 'package:livestock/features/milk_collection/domain/usecases/get_todays_deliveries.dart';
import 'package:livestock/features/milk_collection/domain/usecases/record_delivery.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Provider for milk delivery remote data source
final milkDeliveryRemoteDataSourceProvider =
    Provider<MilkDeliveryRemoteDataSource>((ref) {
  return MilkDeliveryRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Provider for milk delivery repository
final milkDeliveryRepositoryProvider = Provider<MilkDeliveryRepository>((ref) {
  return MilkDeliveryRepositoryImpl(
    remoteDataSource: ref.watch(milkDeliveryRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Provider for record delivery use case
final recordDeliveryUseCaseProvider = Provider<RecordDelivery>((ref) {
  return RecordDelivery(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for get delivery history use case
final getDeliveryHistoryUseCaseProvider = Provider<GetDeliveryHistory>((ref) {
  return GetDeliveryHistory(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for get today's deliveries use case
final getTodaysDeliveriesUseCaseProvider = Provider<GetTodaysDeliveries>((ref) {
  return GetTodaysDeliveries(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for calculate payment use case
final calculatePaymentUseCaseProvider = Provider<CalculatePayment>((ref) {
  return CalculatePayment(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for get deliveries by collection centre use case
final getDeliveriesByCollectionCentreUseCaseProvider =
    Provider<GetDeliveriesByCollectionCentre>((ref) {
  return GetDeliveriesByCollectionCentre(
      ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for today's deliveries
/// Takes cooperativeId as parameter
final todaysDeliveriesProvider = FutureProvider.family(
    (ref, String cooperativeId) async {
  final useCase = ref.watch(getTodaysDeliveriesUseCaseProvider);
  return await useCase(cooperativeId);
});
