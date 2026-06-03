import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/gender_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/age_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/geographic_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/credit_score_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';

/// Comprehensive farmer demographics and statistics
class FarmerMetrics extends Equatable {
  final int totalFarmers;
  final int newFarmersThisPeriod;
  final GenderDistribution genderDistribution;
  final AgeDistribution ageDistribution;
  final GeographicDistribution geographicDistribution;
  final int farmersWithAppAccess;
  final CreditScoreDistribution creditScoreDistribution;
  final List<TimeSeriesDataPoint> registrationTrend;

  const FarmerMetrics({
    required this.totalFarmers,
    required this.newFarmersThisPeriod,
    required this.genderDistribution,
    required this.ageDistribution,
    required this.geographicDistribution,
    required this.farmersWithAppAccess,
    required this.creditScoreDistribution,
    required this.registrationTrend,
  });

  /// App adoption percentage
  double get appAdoptionPercentage =>
      totalFarmers > 0 ? (farmersWithAppAccess / totalFarmers) * 100 : 0;

  /// Farmers without app access
  int get farmersWithoutAppAccess => totalFarmers - farmersWithAppAccess;

  /// Growth rate (new farmers as percentage of total)
  double get growthRate =>
      totalFarmers > 0 ? (newFarmersThisPeriod / totalFarmers) * 100 : 0;

  /// Male percentage
  double get malePercentage => genderDistribution.malePercentage;

  /// Female percentage
  double get femalePercentage => genderDistribution.femalePercentage;

  /// Average age bracket (most common)
  String get dominantAgeBracket {
    final ageMap = ageDistribution.toMap();
    if (ageMap.isEmpty) return 'Unknown';

    var maxCount = 0;
    var dominantBracket = '';

    ageMap.forEach((bracket, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantBracket = bracket;
      }
    });

    return dominantBracket;
  }

  /// Top region by farmer count
  String? get topRegion {
    final topRegions = geographicDistribution.getTopRegions(1);
    return topRegions.isNotEmpty ? topRegions.first.key : null;
  }

  @override
  List<Object?> get props => [
        totalFarmers,
        newFarmersThisPeriod,
        genderDistribution,
        ageDistribution,
        geographicDistribution,
        farmersWithAppAccess,
        creditScoreDistribution,
        registrationTrend,
      ];

  FarmerMetrics copyWith({
    int? totalFarmers,
    int? newFarmersThisPeriod,
    GenderDistribution? genderDistribution,
    AgeDistribution? ageDistribution,
    GeographicDistribution? geographicDistribution,
    int? farmersWithAppAccess,
    CreditScoreDistribution? creditScoreDistribution,
    List<TimeSeriesDataPoint>? registrationTrend,
  }) {
    return FarmerMetrics(
      totalFarmers: totalFarmers ?? this.totalFarmers,
      newFarmersThisPeriod:
          newFarmersThisPeriod ?? this.newFarmersThisPeriod,
      genderDistribution: genderDistribution ?? this.genderDistribution,
      ageDistribution: ageDistribution ?? this.ageDistribution,
      geographicDistribution:
          geographicDistribution ?? this.geographicDistribution,
      farmersWithAppAccess: farmersWithAppAccess ?? this.farmersWithAppAccess,
      creditScoreDistribution:
          creditScoreDistribution ?? this.creditScoreDistribution,
      registrationTrend: registrationTrend ?? this.registrationTrend,
    );
  }
}
