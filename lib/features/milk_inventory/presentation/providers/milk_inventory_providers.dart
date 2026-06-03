import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/features/milk_inventory/data/repositories/milk_inventory_repository_impl.dart';
import 'package:livestock/features/milk_inventory/domain/entities/milk_inventory.dart';
import 'package:livestock/features/milk_inventory/domain/repositories/milk_inventory_repository.dart';

// Repository provider
final milkInventoryRepositoryProvider = Provider<MilkInventoryRepository>((ref) {
  final deliveryRepository = ref.watch(milkDeliveryRepositoryProvider);
  final farmerRepository = ref.watch(farmerRepositoryProvider);
  
  return MilkInventoryRepositoryImpl(
    deliveryRepository: deliveryRepository,
    farmerRepository: farmerRepository,
  );
});

// Current inventory stream provider
final currentMilkInventoryProvider = StreamProvider<MilkInventory>((ref) {
  final repository = ref.watch(milkInventoryRepositoryProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return Stream.value(
      MilkInventory(
        cooperativeId: '',
        totalQuantity: 0.0,
        quantityByGrade: {},
        batches: [],
        lastUpdated: DateTime.now(),
      ),
    );
  }

  return repository.getInventory(cooperativeId);
});

// Total available quantity provider
final totalAvailableQuantityProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(milkInventoryRepositoryProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return 0.0;
  }

  return await repository.getTotalAvailableQuantity(cooperativeId);
});
