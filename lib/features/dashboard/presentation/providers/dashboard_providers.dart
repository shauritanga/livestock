import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/dashboard/domain/entities/collection_trend_data.dart';
import 'package:livestock/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:livestock/features/dashboard/domain/entities/trend_period.dart';
import 'package:livestock/features/dashboard/domain/usecases/get_collection_trend.dart';
import 'package:livestock/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/features/milk_inventory/presentation/providers/milk_inventory_providers.dart';
import 'package:livestock/features/milk_sales/presentation/providers/milk_sale_providers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';

/// Provider for GetDashboardSummary use case
final getDashboardSummaryProvider = Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for GetCollectionTrend use case
final getCollectionTrendProvider = Provider<GetCollectionTrend>((ref) {
  return GetCollectionTrend(ref.watch(milkDeliveryRepositoryProvider));
});

/// Provider for dashboard summary data
/// Uses caching to avoid unnecessary Firestore reads
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  // Keep the provider alive to cache data until explicitly invalidated
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);
  final useCase = ref.watch(getDashboardSummaryProvider);

  if (user == null || user.cooperativeId == null) {
    throw Exception('User not authenticated or no cooperative assigned');
  }

  final result = await useCase(
    user.cooperativeId!,
  );

  return result.fold(
    onError: (failure) => throw Exception(failure.message),
    onSuccess: (summary) => summary,
  );
});

/// Notifier for selected trend period
class SelectedTrendPeriodNotifier extends Notifier<TrendPeriod> {
  @override
  TrendPeriod build() => TrendPeriod.week;

  void setPeriod(TrendPeriod period) {
    state = period;
  }
}

/// Provider for selected trend period
final selectedTrendPeriodProvider =
    NotifierProvider<SelectedTrendPeriodNotifier, TrendPeriod>(
  SelectedTrendPeriodNotifier.new,
);

/// Provider for collection trend data
/// Uses caching to avoid unnecessary Firestore reads
final collectionTrendProvider = FutureProvider<CollectionTrendData>((ref) async {
  // Keep the provider alive to cache data until explicitly invalidated
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);
  final period = ref.watch(selectedTrendPeriodProvider);
  final useCase = ref.watch(getCollectionTrendProvider);

  if (user == null || user.cooperativeId == null) {
    throw Exception('User not authenticated or no cooperative assigned');
  }

  final result = await useCase(user.cooperativeId!, period);

  return result.fold(
    onError: (failure) => throw Exception(failure.message),
    onSuccess: (data) => data,
  );
});

/// Provider for recent deliveries (last 5)
/// Uses caching to avoid unnecessary Firestore reads
final recentDeliveriesProvider = FutureProvider<List<MilkDelivery>>((ref) async {
  // Keep the provider alive to cache data until explicitly invalidated
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || user.cooperativeId == null) {
    return [];
  }

  final repository = ref.watch(milkDeliveryRepositoryProvider);
  final result = await repository.getTodaysDeliveries(
    user.cooperativeId!,
  );

  return result.fold(
    onError: (failure) => [],
    onSuccess: (deliveries) => deliveries.take(5).toList(),
  );
});

// ============================================================================
// FARMER DASHBOARD PROVIDERS
// ============================================================================

/// Provider for farmer monthly summary (current month)
final farmerMonthlySummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || !user.isFarmer) {
    throw Exception('User not authenticated as farmer');
  }

  final repository = ref.watch(milkDeliveryRepositoryProvider);
  
  // Get current month's start and end dates
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  
  // Fetch deliveries for current month
  final result = await repository.getDeliveryHistory(
    user.uid, // farmerId is the user's uid
    startDate: startOfMonth,
    endDate: endOfMonth,
  );

  return result.fold(
    onError: (failure) => {
      'totalLiters': 0.0,
      'deliveryCount': 0,
      'totalEarnings': 0.0,
    },
    onSuccess: (deliveries) {
      double totalLiters = 0.0;
      double totalEarnings = 0.0;
      
      for (final delivery in deliveries) {
        totalLiters += delivery.quantityLiters;
        totalEarnings += delivery.totalAmount;
      }
      
      return {
        'totalLiters': totalLiters,
        'deliveryCount': deliveries.length,
        'totalEarnings': totalEarnings,
      };
    },
  );
});

/// Provider for farmer pending payment amount
final farmerPendingPaymentProvider = FutureProvider<double>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || !user.isFarmer) {
    return 0.0;
  }

  // TODO: Implement actual pending payment calculation
  // This should fetch from a payments collection or calculate from deliveries
  // For now, returning 0 as placeholder
  return 0.0;
});

/// Provider for farmer active loan balance
final farmerActiveLoanBalanceProvider = FutureProvider<double>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || !user.isFarmer) {
    return 0.0;
  }

  // TODO: Implement actual loan balance fetching
  // This should query the loans collection for active loans
  // For now, returning 0 as placeholder
  return 0.0;
});

/// Provider for farmer insurance status
final farmerInsuranceStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || !user.isFarmer) {
    return {
      'isActive': false,
      'coveredCattle': 0,
    };
  }

  // TODO: Implement actual insurance status fetching
  // This should query the insurance policies collection
  // For now, returning inactive status as placeholder
  return {
    'isActive': false,
    'coveredCattle': 0,
  };
});

// ============================================================================
// COLLECTION AGENT DASHBOARD - INVENTORY & SALES PROVIDERS
// ============================================================================

/// Provider for today's sales summary
final todaysSalesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || user.cooperativeId == null) {
    return {
      'totalLiters': 0.0,
      'totalRevenue': 0.0,
      'salesCount': 0,
    };
  }

  // Import the milk sales repository dynamically
  final milkSalesRepository = ref.watch(milkSaleRepositoryProvider);
  
  try {
    // Get all sales for the cooperative
    final allSales = await milkSalesRepository.getSalesByCooperative(user.cooperativeId!);
    
    // Filter for today's sales
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    final todaysSales = allSales.where((sale) {
      return sale.saleDate.isAfter(startOfDay) && sale.saleDate.isBefore(endOfDay);
    }).toList();
    
    double totalLiters = 0.0;
    double totalRevenue = 0.0;
    
    for (final sale in todaysSales) {
      totalLiters += sale.quantityLiters;
      totalRevenue += sale.totalAmount;
    }
    
    return {
      'totalLiters': totalLiters,
      'totalRevenue': totalRevenue,
      'salesCount': todaysSales.length,
    };
  } catch (e) {
    return {
      'totalLiters': 0.0,
      'totalRevenue': 0.0,
      'salesCount': 0,
    };
  }
});

/// Provider for current inventory status (simplified - no batches)
final inventoryStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || user.cooperativeId == null) {
    return {
      'totalQuantity': 0.0,
      'hasLowStock': false,
    };
  }

  try {
    // Get milk product from general inventory
    // Assuming milk has SKU 'MILK-001' or similar
    // You can adjust this to match your actual milk product identification
    final inventoryRepository = ref.watch(milkInventoryRepositoryProvider);
    final totalQuantity = await inventoryRepository.getTotalAvailableQuantity(user.cooperativeId!);
    
    // Simple low stock check (less than 50 liters)
    final hasLowStock = totalQuantity < 50.0;
    
    return {
      'totalQuantity': totalQuantity,
      'hasLowStock': hasLowStock,
    };
  } catch (e) {
    return {
      'totalQuantity': 0.0,
      'hasLowStock': false,
    };
  }
});

/// Provider for top farmers this month
final topFarmersThisMonthProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.keepAlive();
  
  final user = ref.watch(currentAuthUserProvider);

  if (user == null || user.cooperativeId == null) {
    return [];
  }

  final deliveryRepository = ref.watch(milkDeliveryRepositoryProvider);
  final farmerRepository = ref.watch(farmerRepositoryProvider);
  
  try {
    // Get current month's start and end dates
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    // Get all deliveries for the cooperative this month
    final result = await deliveryRepository.getDeliveriesByCooperative(
      user.cooperativeId!,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    
    final deliveries = await result.fold(
      onError: (failure) => <MilkDelivery>[],
      onSuccess: (deliveries) => deliveries,
    );
    
    if (deliveries.isEmpty) {
      return [];
    }
    
    // Group deliveries by farmer and calculate totals
    final Map<String, Map<String, dynamic>> farmerStats = {};
    
    for (final delivery in deliveries) {
      if (!farmerStats.containsKey(delivery.farmerId)) {
        farmerStats[delivery.farmerId] = {
          'farmerId': delivery.farmerId,
          'farmerName': 'Loading...', // Placeholder
          'totalLiters': 0.0,
          'deliveryCount': 0,
          'totalAmount': 0.0,
        };
      }
      
      farmerStats[delivery.farmerId]!['totalLiters'] = 
        (farmerStats[delivery.farmerId]!['totalLiters'] as double) + delivery.quantityLiters;
      farmerStats[delivery.farmerId]!['deliveryCount'] = 
        (farmerStats[delivery.farmerId]!['deliveryCount'] as int) + 1;
      farmerStats[delivery.farmerId]!['totalAmount'] = 
        (farmerStats[delivery.farmerId]!['totalAmount'] as double) + delivery.totalAmount;
    }
    
    // Fetch farmer names
    for (final farmerId in farmerStats.keys) {
      final farmerResult = await farmerRepository.getFarmerById(farmerId);
      farmerResult.fold(
        onError: (_) {
          farmerStats[farmerId]!['farmerName'] = 'Unknown Farmer';
        },
        onSuccess: (farmer) {
          farmerStats[farmerId]!['farmerName'] = farmer.name;
        },
      );
    }
    
    // Convert to list and sort by total liters (descending)
    final topFarmers = farmerStats.values.toList()
      ..sort((a, b) => (b['totalLiters'] as double).compareTo(a['totalLiters'] as double));
    
    // Return top 5 farmers
    return topFarmers.take(5).toList();
  } catch (e) {
    return [];
  }
});
