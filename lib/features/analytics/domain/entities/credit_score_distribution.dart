import 'package:equatable/equatable.dart';

/// Credit score distribution with score range buckets
class CreditScoreDistribution extends Equatable {
  final int range0to300;
  final int range301to500;
  final int range501to700;
  final int range701to850;

  const CreditScoreDistribution({
    required this.range0to300,
    required this.range301to500,
    required this.range501to700,
    required this.range701to850,
  });

  /// Total count
  int get total =>
      range0to300 + range301to500 + range501to700 + range701to850;

  /// Get percentage for a specific range
  double getPercentage(String range) {
    if (total == 0) return 0;

    switch (range) {
      case '0-300':
        return (range0to300 / total) * 100;
      case '301-500':
        return (range301to500 / total) * 100;
      case '501-700':
        return (range501to700 / total) * 100;
      case '701-850':
        return (range701to850 / total) * 100;
      default:
        return 0;
    }
  }

  /// Get distribution as map
  Map<String, int> toMap() {
    return {
      '0-300': range0to300,
      '301-500': range301to500,
      '501-700': range501to700,
      '701-850': range701to850,
    };
  }

  /// Average credit score category
  String get averageCategory {
    if (total == 0) return 'Unknown';

    final weightedSum = (range0to300 * 150) +
        (range301to500 * 400) +
        (range501to700 * 600) +
        (range701to850 * 775);
    final average = weightedSum / total;

    if (average < 300) return 'Poor';
    if (average < 500) return 'Fair';
    if (average < 700) return 'Good';
    return 'Excellent';
  }

  @override
  List<Object?> get props => [
        range0to300,
        range301to500,
        range501to700,
        range701to850,
      ];

  CreditScoreDistribution copyWith({
    int? range0to300,
    int? range301to500,
    int? range501to700,
    int? range701to850,
  }) {
    return CreditScoreDistribution(
      range0to300: range0to300 ?? this.range0to300,
      range301to500: range301to500 ?? this.range301to500,
      range501to700: range501to700 ?? this.range501to700,
      range701to850: range701to850 ?? this.range701to850,
    );
  }
}
