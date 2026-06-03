import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/repositories/farmer_repository.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';
import 'package:livestock/features/milk_inventory/domain/entities/inventory_batch.dart';
import 'package:livestock/features/milk_inventory/domain/entities/milk_inventory.dart';
import 'package:livestock/features/milk_inventory/domain/repositories/milk_inventory_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Implementation of milk inventory repository
class MilkInventoryRepositoryImpl implements MilkInventoryRepository {
  final MilkDeliveryRepository _deliveryRepository;
  final FarmerRepository _farmerRepository;

  MilkInventoryRepositoryImpl({
    required MilkDeliveryRepository deliveryRepository,
    required FarmerRepository farmerRepository,
  })  : _deliveryRepository = deliveryRepository,
        _farmerRepository = farmerRepository;

  @override
  Stream<MilkInventory> getInventory(String cooperativeId) async* {
    // Stream deliveries and calculate inventory
    await for (final deliveriesResult in _deliveryRepository.streamDeliveries(cooperativeId)) {
      final deliveries = deliveriesResult.fold(
        onError: (_) => <MilkDelivery>[],
        onSuccess: (deliveries) => deliveries,
      );

      // Filter unpaid deliveries (available inventory)
      final availableDeliveries = deliveries.where((d) => !d.isPaid).toList();

      // Calculate total quantity
      final totalQuantity = availableDeliveries.fold<double>(
        0.0,
        (sum, delivery) => sum + delivery.quantityLiters,
      );

      // Calculate quantity by grade
      final quantityByGrade = <MilkQualityGrade, double>{};
      for (final grade in MilkQualityGrade.values) {
        quantityByGrade[grade] = availableDeliveries
            .where((d) => d.qualityGrade == grade)
            .fold<double>(0.0, (sum, d) => sum + d.quantityLiters);
      }

      // Get farmers for batch information
      final farmersResult = await _farmerRepository.getFarmersByCooperative(cooperativeId);
      final farmers = farmersResult.fold(
        onError: (_) => <Farmer>[],
        onSuccess: (farmers) => farmers,
      );

      // Create farmer map for quick lookup
      final farmerMap = {for (var f in farmers) f.id: f};

      // Create inventory batches
      final batches = availableDeliveries.map((delivery) {
        final farmer = farmerMap[delivery.farmerId];
        return InventoryBatch(
          deliveryId: delivery.id,
          farmerId: delivery.farmerId,
          farmerName: farmer?.name ?? 'Unknown',
          quantity: delivery.quantityLiters,
          grade: delivery.qualityGrade,
          collectionDate: delivery.deliveryDate,
        );
      }).toList();

      // Sort batches by collection date (oldest first)
      batches.sort((a, b) => a.collectionDate.compareTo(b.collectionDate));

      yield MilkInventory(
        cooperativeId: cooperativeId,
        totalQuantity: totalQuantity,
        quantityByGrade: quantityByGrade,
        batches: batches,
        lastUpdated: DateTime.now(),
      );
    }
  }

  @override
  Future<double> getTotalAvailableQuantity(String cooperativeId) async {
    final deliveriesResult = await _deliveryRepository.getDeliveriesByCooperative(cooperativeId);
    
    final deliveries = deliveriesResult.fold(
      onError: (_) => <MilkDelivery>[],
      onSuccess: (deliveries) => deliveries,
    );

    // Sum up all deliveries (total collected)
    final totalCollected = deliveries.fold<double>(0.0, (sum, d) => sum + d.quantityLiters);
    
    // Get total milk sales from Firestore
    try {
      final salesSnapshot = await FirebaseFirestore.instance
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('milk_sales')
          .get();
      
      final totalSold = salesSnapshot.docs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc.data()['quantityLiters'] as num? ?? 0).toDouble(),
      );
      
      // Available = Collected - Sold
      return (totalCollected - totalSold).clamp(0.0, double.infinity);
    } catch (e) {
      // If sales fetch fails, return total collected
      return totalCollected;
    }
  }

  @override
  Future<List<InventoryBatch>> getInventoryBatches(String cooperativeId) async {
    final deliveriesResult = await _deliveryRepository.getDeliveriesByCooperative(cooperativeId);
    
    final deliveries = deliveriesResult.fold(
      onError: (_) => <MilkDelivery>[],
      onSuccess: (deliveries) => deliveries,
    );

    // Filter unpaid deliveries
    final availableDeliveries = deliveries.where((d) => !d.isPaid).toList();

    // Get farmers
    final farmersResult = await _farmerRepository.getFarmersByCooperative(cooperativeId);
    final farmers = farmersResult.fold(
      onError: (_) => <Farmer>[],
      onSuccess: (farmers) => farmers,
    );

    final farmerMap = {for (var f in farmers) f.id: f};

    // Create batches
    final batches = availableDeliveries.map((delivery) {
      final farmer = farmerMap[delivery.farmerId];
      return InventoryBatch(
        deliveryId: delivery.id,
        farmerId: delivery.farmerId,
        farmerName: farmer?.name ?? 'Unknown',
        quantity: delivery.quantityLiters,
        grade: delivery.qualityGrade,
        collectionDate: delivery.deliveryDate,
      );
    }).toList();

    // Sort by collection date (oldest first)
    batches.sort((a, b) => a.collectionDate.compareTo(b.collectionDate));

    return batches;
  }
}
