import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/date_range.dart';

/// Filter for analytics queries
class AnalyticsFilter extends Equatable {
  final DateRange dateRange;
  final List<String>? cooperativeIds;
  final List<String>? collectionCenterIds;
  final String? region;
  final String? district;
  final String? ward;
  final String? village;

  const AnalyticsFilter({
    required this.dateRange,
    this.cooperativeIds,
    this.collectionCenterIds,
    this.region,
    this.district,
    this.ward,
    this.village,
  });

  /// Factory: Today's data
  factory AnalyticsFilter.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return AnalyticsFilter(
      dateRange: DateRange(startDate: startOfDay, endDate: endOfDay),
    );
  }

  /// Factory: This week's data
  factory AnalyticsFilter.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return AnalyticsFilter(
      dateRange: DateRange(startDate: startDate, endDate: endDate),
    );
  }

  /// Factory: This month's data
  factory AnalyticsFilter.thisMonth() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return AnalyticsFilter(
      dateRange: DateRange(startDate: startDate, endDate: endDate),
    );
  }

  /// Factory: This quarter's data
  factory AnalyticsFilter.thisQuarter() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    final startMonth = (quarter - 1) * 3 + 1;
    final startDate = DateTime(now.year, startMonth, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return AnalyticsFilter(
      dateRange: DateRange(startDate: startDate, endDate: endDate),
    );
  }

  /// Factory: This year's data
  factory AnalyticsFilter.thisYear() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return AnalyticsFilter(
      dateRange: DateRange(startDate: startDate, endDate: endDate),
    );
  }

  /// Factory: Custom date range
  factory AnalyticsFilter.custom(DateRange range) {
    return AnalyticsFilter(dateRange: range);
  }

  @override
  List<Object?> get props => [
        dateRange,
        cooperativeIds,
        collectionCenterIds,
        region,
        district,
        ward,
        village,
      ];

  AnalyticsFilter copyWith({
    DateRange? dateRange,
    List<String>? cooperativeIds,
    List<String>? collectionCenterIds,
    String? region,
    String? district,
    String? ward,
    String? village,
  }) {
    return AnalyticsFilter(
      dateRange: dateRange ?? this.dateRange,
      cooperativeIds: cooperativeIds ?? this.cooperativeIds,
      collectionCenterIds: collectionCenterIds ?? this.collectionCenterIds,
      region: region ?? this.region,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      village: village ?? this.village,
    );
  }
}
