import 'package:equatable/equatable.dart';

/// Gender distribution statistics
class GenderDistribution extends Equatable {
  final int maleCount;
  final int femaleCount;

  const GenderDistribution({
    required this.maleCount,
    required this.femaleCount,
  });

  /// Total count
  int get total => maleCount + femaleCount;

  /// Male percentage
  double get malePercentage => total > 0 ? (maleCount / total) * 100 : 0;

  /// Female percentage
  double get femalePercentage => total > 0 ? (femaleCount / total) * 100 : 0;

  @override
  List<Object?> get props => [maleCount, femaleCount];

  GenderDistribution copyWith({
    int? maleCount,
    int? femaleCount,
  }) {
    return GenderDistribution(
      maleCount: maleCount ?? this.maleCount,
      femaleCount: femaleCount ?? this.femaleCount,
    );
  }
}
