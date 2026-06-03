import '../../domain/entities/milk_production_metrics.dart';
import '../../domain/entities/collection_center_metrics.dart';
import '../../domain/entities/quality_distribution.dart';
import '../../domain/entities/time_series_data_point.dart';

class MilkProductionMetricsModel extends MilkProductionMetrics {
  const MilkProductionMetricsModel({
    required super.totalLiters,
    required super.averageLitersPerDay,
    required super.averageLitersPerFarmer,
    required super.qualityDistribution,
    required super.dailyTrend,
    required super.centerBreakdown,
    required super.hourlyDistribution,
    required super.percentageChange,
  });

  factory MilkProductionMetricsModel.fromJson(Map<String, dynamic> json) {
    return MilkProductionMetricsModel(
      totalLiters: (json['totalLiters'] as num).toDouble(),
      averageLitersPerDay: (json['averageLitersPerDay'] as num).toDouble(),
      averageLitersPerFarmer: (json['averageLitersPerFarmer'] as num).toDouble(),
      qualityDistribution: QualityDistribution(
        premiumCount: json['qualityDistribution']['premium'] as int,
        standardCount: json['qualityDistribution']['standard'] as int,
        substandardCount: json['qualityDistribution']['substandard'] as int,
      ),
      dailyTrend: (json['dailyTrend'] as List)
          .map((e) => TimeSeriesDataPoint(
                date: DateTime.parse(e['date'] as String),
                value: (e['value'] as num).toDouble(),
              ))
          .toList(),
      centerBreakdown: (json['centerBreakdown'] as List)
          .map((e) => CollectionCenterMetrics(
                centerId: e['centerId'] as String,
                centerName: e['centerName'] as String,
                totalLiters: (e['totalLiters'] as num).toDouble(),
                farmerCount: e['farmerCount'] as int,
                percentageOfTotal: (e['percentageOfTotal'] as num).toDouble(),
              ))
          .toList(),
      hourlyDistribution: Map<int, double>.from(
        (json['hourlyDistribution'] as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), (value as num).toDouble()),
        ),
      ),
      percentageChange: (json['percentageChange'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLiters': totalLiters,
      'averageLitersPerDay': averageLitersPerDay,
      'averageLitersPerFarmer': averageLitersPerFarmer,
      'qualityDistribution': {
        'premium': qualityDistribution.premiumCount,
        'standard': qualityDistribution.standardCount,
        'substandard': qualityDistribution.substandardCount,
      },
      'dailyTrend': dailyTrend
          .map((e) => {
                'date': e.date.toIso8601String(),
                'value': e.value,
              })
          .toList(),
      'centerBreakdown': centerBreakdown
          .map((e) => {
                'centerId': e.centerId,
                'centerName': e.centerName,
                'totalLiters': e.totalLiters,
                'farmerCount': e.farmerCount,
                'percentageOfTotal': e.percentageOfTotal,
                'averageLitersPerFarmer': e.averageLitersPerFarmer,
              })
          .toList(),
      'hourlyDistribution': hourlyDistribution.map((key, value) => MapEntry(key.toString(), value)),
      'percentageChange': percentageChange,
    };
  }
}
