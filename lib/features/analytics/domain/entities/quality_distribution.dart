import 'package:equatable/equatable.dart';

/// Milk quality distribution statistics
class QualityDistribution extends Equatable {
  final int premiumCount;
  final int standardCount;
  final int substandardCount;

  const QualityDistribution({
    required this.premiumCount,
    required this.standardCount,
    required this.substandardCount,
  });

  /// Total count
  int get total => premiumCount + standardCount + substandardCount;

  /// Premium percentage
  double get premiumPercentage => total > 0 ? (premiumCount / total) * 100 : 0;

  /// Standard percentage
  double get standardPercentage =>
      total > 0 ? (standardCount / total) * 100 : 0;

  /// Substandard percentage
  double get substandardPercentage =>
      total > 0 ? (substandardCount / total) * 100 : 0;

  /// Get distribution as map
  Map<String, int> toMap() {
    return {
      'Premium': premiumCount,
      'Standard': standardCount,
      'Substandard': substandardCount,
    };
  }

  @override
  List<Object?> get props => [premiumCount, standardCount, substandardCount];

  QualityDistribution copyWith({
    int? premiumCount,
    int? standardCount,
    int? substandardCount,
  }) {
    return QualityDistribution(
      premiumCount: premiumCount ?? this.premiumCount,
      standardCount: standardCount ?? this.standardCount,
      substandardCount: substandardCount ?? this.substandardCount,
    );
  }
}
