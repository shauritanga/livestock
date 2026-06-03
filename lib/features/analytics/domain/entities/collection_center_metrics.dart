import 'package:equatable/equatable.dart';

/// Metrics for a single collection center
class CollectionCenterMetrics extends Equatable {
  final String centerId;
  final String centerName;
  final double totalLiters;
  final int farmerCount;
  final double percentageOfTotal;

  const CollectionCenterMetrics({
    required this.centerId,
    required this.centerName,
    required this.totalLiters,
    required this.farmerCount,
    required this.percentageOfTotal,
  });

  /// Average liters per farmer
  double get averageLitersPerFarmer =>
      farmerCount > 0 ? totalLiters / farmerCount : 0;

  @override
  List<Object?> get props => [
        centerId,
        centerName,
        totalLiters,
        farmerCount,
        percentageOfTotal,
      ];

  CollectionCenterMetrics copyWith({
    String? centerId,
    String? centerName,
    double? totalLiters,
    int? farmerCount,
    double? percentageOfTotal,
  }) {
    return CollectionCenterMetrics(
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      totalLiters: totalLiters ?? this.totalLiters,
      farmerCount: farmerCount ?? this.farmerCount,
      percentageOfTotal: percentageOfTotal ?? this.percentageOfTotal,
    );
  }
}
