import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/milk_inventory/presentation/providers/milk_inventory_providers.dart';
import 'package:livestock/features/milk_sales/data/datasources/milk_sale_remote_datasource.dart';
import 'package:livestock/features/milk_sales/data/repositories/milk_sale_repository_impl.dart';
import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';
import 'package:livestock/features/milk_sales/domain/repositories/milk_sale_repository.dart';
import 'package:livestock/features/milk_sales/domain/usecases/record_milk_sale.dart';

// Data source provider
final milkSaleRemoteDataSourceProvider = Provider<MilkSaleRemoteDataSource>((ref) {
  return MilkSaleRemoteDataSource(firestore: FirebaseFirestore.instance);
});

// Repository provider
final milkSaleRepositoryProvider = Provider<MilkSaleRepository>((ref) {
  final remoteDataSource = ref.watch(milkSaleRemoteDataSourceProvider);
  final inventoryRepository = ref.watch(milkInventoryRepositoryProvider);
  
  return MilkSaleRepositoryImpl(
    remoteDataSource: remoteDataSource,
    inventoryRepository: inventoryRepository,
  );
});

// Use case provider
final recordMilkSaleUseCaseProvider = Provider<RecordMilkSale>((ref) {
  final repository = ref.watch(milkSaleRepositoryProvider);
  return RecordMilkSale(repository);
});

// All milk sales provider
final milkSalesProvider = FutureProvider<List<MilkSale>>((ref) async {
  final repository = ref.watch(milkSaleRepositoryProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return [];
  }

  try {
    return await repository.getSalesByCooperative(cooperativeId);
  } catch (e) {
    throw Exception('Failed to load milk sales: $e');
  }
});
