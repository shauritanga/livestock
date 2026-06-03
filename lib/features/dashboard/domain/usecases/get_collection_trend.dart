import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/dashboard/domain/entities/collection_data_point.dart';
import 'package:livestock/features/dashboard/domain/entities/collection_trend_data.dart';
import 'package:livestock/features/dashboard/domain/entities/trend_period.dart';
import 'package:livestock/features/milk_collection/domain/repositories/milk_delivery_repository.dart';

/// Use case for getting collection trend data
class GetCollectionTrend {
  final MilkDeliveryRepository repository;

  GetCollectionTrend(this.repository);

  Future<Result<CollectionTrendData>> call(
    String cooperativeId,
    TrendPeriod period,
  ) async {
    // Calculate date range based on period
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime startDate;
    // Set endDate to end of today (23:59:59) to include all of today's deliveries
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (period == TrendPeriod.week) {
      // For weekly view, show last 7 days (today + 6 days before)
      startDate = today.subtract(const Duration(days: 6));
    } else {
      // For month and year, go back by the period days
      startDate = today.subtract(Duration(days: period.days));
    }

    // Fetch deliveries for the date range
    final result = await repository.getDeliveriesByCooperative(
      cooperativeId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      onError: (failure) => Error(failure),
      onSuccess: (deliveries) {
        final dataPoints = <CollectionDataPoint>[];

        switch (period) {
          case TrendPeriod.week:
            // Group by day - show all 7 days (Mon-Sun)
            dataPoints.addAll(_groupByDay(deliveries, startDate, 7));
            break;

          case TrendPeriod.month:
            // Group by week - show 4-5 weeks
            dataPoints.addAll(_groupByWeek(deliveries, startDate, endDate));
            break;

          case TrendPeriod.year:
            // Group by month - show all 12 months
            dataPoints.addAll(_groupByMonth(deliveries, endDate));
            break;
        }

        // Calculate statistics
        final totalVolume = dataPoints.fold<double>(
          0.0,
          (sum, point) => sum + point.volumeLiters,
        );

        final averageVolume = dataPoints.isNotEmpty
            ? totalVolume / dataPoints.length
            : 0.0;

        final trendData = CollectionTrendData(
          dataPoints: dataPoints,
          period: period,
          averageVolume: averageVolume,
          totalVolume: totalVolume,
        );

        return Success(trendData);
      },
    );
  }

  /// Group deliveries by day (for weekly view)
  List<CollectionDataPoint> _groupByDay(
    List<dynamic> deliveries,
    DateTime startDate,
    int days,
  ) {
    // Use string keys for reliable date comparison
    final Map<String, List<dynamic>> groupedByDate = {};

    for (final delivery in deliveries) {
      final date = delivery.deliveryDate;
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(delivery);
    }

    final dataPoints = <CollectionDataPoint>[];

    for (int i = 0; i < days; i++) {
      // Use add() to properly handle month/year boundaries
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      ).add(Duration(days: i));
      
      // Create date key for lookup
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final deliveriesForDate = groupedByDate[dateKey] ?? [];

      final volumeLiters = deliveriesForDate.fold<double>(
        0.0,
        (sum, delivery) => sum + delivery.quantityLiters,
      );

      final uniqueFarmers = deliveriesForDate
          .map((d) => d.farmerId)
          .toSet()
          .length;

      dataPoints.add(CollectionDataPoint(
        date: date,
        volumeLiters: volumeLiters,
        farmerCount: uniqueFarmers,
      ));
    }

    return dataPoints;
  }

  /// Group deliveries by week (for monthly view)
  List<CollectionDataPoint> _groupByWeek(
    List<dynamic> deliveries,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Calculate number of weeks
    final daysDiff = endDate.difference(startDate).inDays;
    final weeks = (daysDiff / 7).ceil();

    final Map<int, List<dynamic>> groupedByWeek = {};

    for (final delivery in deliveries) {
      final daysSinceStart = delivery.deliveryDate.difference(startDate).inDays;
      final weekNumber = (daysSinceStart / 7).floor();

      if (!groupedByWeek.containsKey(weekNumber)) {
        groupedByWeek[weekNumber] = [];
      }
      groupedByWeek[weekNumber]!.add(delivery);
    }

    final dataPoints = <CollectionDataPoint>[];

    for (int i = 0; i < weeks; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final deliveriesForWeek = groupedByWeek[i] ?? [];

      final volumeLiters = deliveriesForWeek.fold<double>(
        0.0,
        (sum, delivery) => sum + delivery.quantityLiters,
      );

      final uniqueFarmers = deliveriesForWeek
          .map((d) => d.farmerId)
          .toSet()
          .length;

      dataPoints.add(CollectionDataPoint(
        date: weekStart,
        volumeLiters: volumeLiters,
        farmerCount: uniqueFarmers,
      ));
    }

    return dataPoints;
  }

  /// Group deliveries by month (for yearly view)
  List<CollectionDataPoint> _groupByMonth(
    List<dynamic> deliveries,
    DateTime endDate,
  ) {
    final Map<String, List<dynamic>> groupedByMonth = {};

    for (final delivery in deliveries) {
      final monthKey = '${delivery.deliveryDate.year}-${delivery.deliveryDate.month.toString().padLeft(2, '0')}';

      if (!groupedByMonth.containsKey(monthKey)) {
        groupedByMonth[monthKey] = [];
      }
      groupedByMonth[monthKey]!.add(delivery);
    }

    final dataPoints = <CollectionDataPoint>[];

    // Always show all 12 months, even if no data
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(endDate.year, endDate.month - i, 1);
      final monthKey = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

      final deliveriesForMonth = groupedByMonth[monthKey] ?? [];

      final volumeLiters = deliveriesForMonth.fold<double>(
        0.0,
        (sum, delivery) => sum + delivery.quantityLiters,
      );

      final uniqueFarmers = deliveriesForMonth
          .map((d) => d.farmerId)
          .toSet()
          .length;

      dataPoints.add(CollectionDataPoint(
        date: monthDate,
        volumeLiters: volumeLiters,
        farmerCount: uniqueFarmers,
      ));
    }

    return dataPoints;
  }
}
