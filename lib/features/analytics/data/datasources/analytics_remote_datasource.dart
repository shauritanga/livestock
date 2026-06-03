import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:livestock/core/constants/firebase_constants.dart';
import '../models/milk_production_metrics_model.dart';
import '../models/farmer_metrics_model.dart';
import '../models/livestock_metrics_model.dart';
import '../models/financial_metrics_model.dart';
import '../models/inventory_metrics_model.dart';
import '../models/analytics_filter_model.dart';
import '../models/alert_model.dart';

/// Remote data source for analytics data from Firestore and Cloud Functions
/// 
/// This implementation provides basic aggregation queries. In production,
/// complex aggregations should be handled by Cloud Functions for better performance.
class AnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  AnalyticsRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  /// Get milk production metrics (Task 12.1)
  /// 
  /// In production, this should call a Cloud Function for complex aggregations
  Future<MilkProductionMetricsModel> getMilkProductionMetrics(
    AnalyticsFilterModel filter,
  ) async {
    try {
      // Call Cloud Function for aggregation
      final callable = functions.httpsCallable('calculateMilkProductionMetrics');
      final result = await callable.call({
        'filter': filter.toJson(),
      });
      
      return MilkProductionMetricsModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get milk production metrics: $e');
    }
  }

  /// Get farmer metrics (Task 12.1)
  Future<FarmerMetricsModel> getFarmerMetrics(
    AnalyticsFilterModel filter,
  ) async {
    try {
      // Call Cloud Function for aggregation
      final callable = functions.httpsCallable('calculateFarmerDemographics');
      final result = await callable.call({
        'filter': filter.toJson(),
      });
      
      return FarmerMetricsModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get farmer metrics: $e');
    }
  }

  /// Get livestock metrics (Task 12.1)
  Future<LivestockMetricsModel> getLivestockMetrics(
    AnalyticsFilterModel filter,
  ) async {
    try {
      // Call Cloud Function for aggregation
      final callable = functions.httpsCallable('calculateLivestockMetrics');
      final result = await callable.call({
        'filter': filter.toJson(),
      });
      
      return LivestockMetricsModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get livestock metrics: $e');
    }
  }

  /// Get financial metrics (Task 12.2)
  Future<FinancialMetricsModel> getFinancialMetrics(
    AnalyticsFilterModel filter,
  ) async {
    try {
      // Call Cloud Function for aggregation
      final callable = functions.httpsCallable('calculateFinancialMetrics');
      final result = await callable.call({
        'filter': filter.toJson(),
      });
      
      return FinancialMetricsModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get financial metrics: $e');
    }
  }

  /// Get inventory metrics (Task 12.2)
  Future<InventoryMetricsModel> getInventoryMetrics(
    AnalyticsFilterModel filter,
  ) async {
    try {
      // Call Cloud Function for aggregation
      final callable = functions.httpsCallable('calculateInventoryMetrics');
      final result = await callable.call({
        'filter': filter.toJson(),
      });
      
      return InventoryMetricsModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get inventory metrics: $e');
    }
  }

  /// Get comparative metrics (Task 12.3)
  Future<Map<String, dynamic>> getComparativeMetrics(
    AnalyticsFilterModel currentFilter,
    AnalyticsFilterModel comparisonFilter,
  ) async {
    try {
      final callable = functions.httpsCallable('calculateComparativeMetrics');
      final result = await callable.call({
        'currentFilter': currentFilter.toJson(),
        'comparisonFilter': comparisonFilter.toJson(),
      });

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to get comparative metrics: $e');
    }
  }

  /// Get predictive metrics (Task 12.3)
  Future<Map<String, dynamic>> getPredictiveMetrics(
    AnalyticsFilterModel historicalFilter,
    int forecastDays,
  ) async {
    try {
      final callable = functions.httpsCallable('calculatePredictiveMetrics');
      final result = await callable.call({
        'historicalFilter': historicalFilter.toJson(),
        'forecastDays': forecastDays,
      });

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to get predictive metrics: $e');
    }
  }

  /// Get alerts (Task 12.4)
  Future<List<AlertModel>> getAlerts({
    String? minSeverity,
    bool? unreadOnly,
  }) async {
    try {
      Query query = firestore.collection(FirebaseConstants.alertsCollection)
          .orderBy('createdAt', descending: true);

      // Filter by read status if provided
      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Filter by severity if provided
      if (minSeverity != null) {
        query = query.where('severity', isEqualTo: minSeverity);
      }

      final snapshot = await query.limit(100).get();

      return snapshot.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get alerts: $e');
    }
  }

  /// Mark alert as read (Task 12.4)
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await firestore.collection(FirebaseConstants.alertsCollection).doc(alertId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  /// Get alerts stream for real-time updates (Task 12.4)
  Stream<List<AlertModel>> getAlertsStream({
    String? minSeverity,
    bool? unreadOnly,
  }) {
    try {
      Query query = firestore.collection(FirebaseConstants.alertsCollection)
          .orderBy('createdAt', descending: true);

      // Filter by read status if provided
      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Filter by severity if provided
      if (minSeverity != null) {
        query = query.where('severity', isEqualTo: minSeverity);
      }

      return query.limit(100).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get alerts stream: $e');
    }
  }
}
