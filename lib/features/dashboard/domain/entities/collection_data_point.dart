import 'package:equatable/equatable.dart';

/// Collection data point for trend chart visualization
class CollectionDataPoint extends Equatable {
  final DateTime date;
  final double volumeLiters;
  final int farmerCount;

  const CollectionDataPoint({
    required this.date,
    required this.volumeLiters,
    required this.farmerCount,
  });

  @override
  List<Object?> get props => [date, volumeLiters, farmerCount];

  CollectionDataPoint copyWith({
    DateTime? date,
    double? volumeLiters,
    int? farmerCount,
  }) {
    return CollectionDataPoint(
      date: date ?? this.date,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      farmerCount: farmerCount ?? this.farmerCount,
    );
  }
}
