import 'package:equatable/equatable.dart';

import 'collection_data_point.dart';
import 'trend_period.dart';

/// Collection trend data with statistics
class CollectionTrendData extends Equatable {
  final List<CollectionDataPoint> dataPoints;
  final TrendPeriod period;
  final double averageVolume;
  final double totalVolume;

  const CollectionTrendData({
    required this.dataPoints,
    required this.period,
    required this.averageVolume,
    required this.totalVolume,
  });

  @override
  List<Object?> get props => [
        dataPoints,
        period,
        averageVolume,
        totalVolume,
      ];

  CollectionTrendData copyWith({
    List<CollectionDataPoint>? dataPoints,
    TrendPeriod? period,
    double? averageVolume,
    double? totalVolume,
  }) {
    return CollectionTrendData(
      dataPoints: dataPoints ?? this.dataPoints,
      period: period ?? this.period,
      averageVolume: averageVolume ?? this.averageVolume,
      totalVolume: totalVolume ?? this.totalVolume,
    );
  }
}
