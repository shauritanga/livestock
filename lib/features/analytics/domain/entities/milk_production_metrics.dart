import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/quality_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';
import 'package:livestock/features/analytics/domain/entities/collection_center_metrics.dart';

/// Comprehensive milk production analytics metrics
class MilkProductionMetrics extends Equatable {
  final double totalLiters;
  final double averageLitersPerDay;
  final double averageLitersPerFarmer;
  final QualityDistribution qualityDistribution;
  final List<TimeSeriesDataPoint> dailyTrend;
  final List<CollectionCenterMetrics> centerBreakdown;
  final Map<int, double> hourlyDistribution; // hour (0-23) -> liters
  final double percentageChange; // vs previous period

  const MilkProductionMetrics({
    required this.totalLiters,
    required this.averageLitersPerDay,
    required this.averageLitersPerFarmer,
    required this.qualityDistribution,
    required this.dailyTrend,
    required this.centerBreakdown,
    required this.hourlyDistribution,
    required this.percentageChange,
  });

  /// Peak collection hour
  int? get peakCollectionHour {
    if (hourlyDistribution.isEmpty) return null;
    
    var maxHour = 0;
    var maxLiters = 0.0;
    
    hourlyDistribution.forEach((hour, liters) {
      if (liters > maxLiters) {
        maxLiters = liters;
        maxHour = hour;
      }
    });
    
    return maxHour;
  }

  /// Top performing collection center
  CollectionCenterMetrics? get topCenter {
    if (centerBreakdown.isEmpty) return null;
    
    return centerBreakdown.reduce((a, b) =>
        a.totalLiters > b.totalLiters ? a : b);
  }

  /// Quality grade percentage (premium milk)
  double get qualityGradePercentage =>
      qualityDistribution.premiumPercentage;

  @override
  List<Object?> get props => [
        totalLiters,
        averageLitersPerDay,
        averageLitersPerFarmer,
        qualityDistribution,
        dailyTrend,
        centerBreakdown,
        hourlyDistribution,
        percentageChange,
      ];

  MilkProductionMetrics copyWith({
    double? totalLiters,
    double? averageLitersPerDay,
    double? averageLitersPerFarmer,
    QualityDistribution? qualityDistribution,
    List<TimeSeriesDataPoint>? dailyTrend,
    List<CollectionCenterMetrics>? centerBreakdown,
    Map<int, double>? hourlyDistribution,
    double? percentageChange,
  }) {
    return MilkProductionMetrics(
      totalLiters: totalLiters ?? this.totalLiters,
      averageLitersPerDay: averageLitersPerDay ?? this.averageLitersPerDay,
      averageLitersPerFarmer:
          averageLitersPerFarmer ?? this.averageLitersPerFarmer,
      qualityDistribution: qualityDistribution ?? this.qualityDistribution,
      dailyTrend: dailyTrend ?? this.dailyTrend,
      centerBreakdown: centerBreakdown ?? this.centerBreakdown,
      hourlyDistribution: hourlyDistribution ?? this.hourlyDistribution,
      percentageChange: percentageChange ?? this.percentageChange,
    );
  }
}
