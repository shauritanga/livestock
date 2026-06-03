import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/entrance_fee/data/datasources/entrance_fee_remote_datasource.dart';
import 'package:livestock/features/entrance_fee/data/repositories/entrance_fee_repository_impl.dart';
import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';
import 'package:livestock/features/entrance_fee/domain/entities/payment_summary.dart';
import 'package:livestock/features/entrance_fee/domain/repositories/entrance_fee_repository.dart';
import 'package:livestock/features/entrance_fee/domain/usecases/get_all_farmers_payment_status.dart';
import 'package:livestock/features/entrance_fee/domain/usecases/get_payment_summary.dart';
import 'package:livestock/features/entrance_fee/domain/usecases/record_entrance_fee.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';

// Data source provider
final entranceFeeRemoteDataSourceProvider = Provider<EntranceFeeRemoteDataSource>((ref) {
  return EntranceFeeRemoteDataSource(firestore: FirebaseFirestore.instance);
});

// Repository provider
final entranceFeeRepositoryProvider = Provider<EntranceFeeRepository>((ref) {
  final remoteDataSource = ref.watch(entranceFeeRemoteDataSourceProvider);
  final farmerRepository = ref.watch(farmerRepositoryProvider);
  return EntranceFeeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    farmerRepository: farmerRepository,
  );
});

// Use case providers
final recordEntranceFeeUseCaseProvider = Provider<RecordEntranceFee>((ref) {
  final repository = ref.watch(entranceFeeRepositoryProvider);
  return RecordEntranceFee(repository);
});

final getAllFarmersPaymentStatusUseCaseProvider = Provider<GetAllFarmersPaymentStatus>((ref) {
  final repository = ref.watch(entranceFeeRepositoryProvider);
  return GetAllFarmersPaymentStatus(repository);
});

final getPaymentSummaryUseCaseProvider = Provider<GetPaymentSummary>((ref) {
  final repository = ref.watch(entranceFeeRepositoryProvider);
  return GetPaymentSummary(repository);
});

// All farmers payment status stream provider
final allFarmersPaymentStatusProvider = StreamProvider<List<FarmerPaymentStatus>>((ref) {
  final useCase = ref.watch(getAllFarmersPaymentStatusUseCaseProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return Stream.value([]);
  }

  return useCase(cooperativeId);
});

// Payment summary provider
final paymentSummaryProvider = FutureProvider<PaymentSummary>((ref) async {
  final useCase = ref.watch(getPaymentSummaryUseCaseProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return const PaymentSummary(
      totalFarmers: 0,
      paidCount: 0,
      unpaidCount: 0,
      totalAmountCollected: 0.0,
    );
  }

  try {
    return await useCase(cooperativeId);
  } catch (e) {
    throw Exception('Failed to load payment summary: $e');
  }
});
