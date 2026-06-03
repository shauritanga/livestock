import '../../domain/entities/farmer_metrics.dart';
import '../../domain/entities/gender_distribution.dart';
import '../../domain/entities/age_distribution.dart';
import '../../domain/entities/geographic_distribution.dart';
import '../../domain/entities/credit_score_distribution.dart';
import '../../domain/entities/time_series_data_point.dart';

class FarmerMetricsModel extends FarmerMetrics {
  const FarmerMetricsModel({
    required super.totalFarmers,
    required super.newFarmersThisPeriod,
    required super.genderDistribution,
    required super.ageDistribution,
    required super.geographicDistribution,
    required super.farmersWithAppAccess,
    required super.creditScoreDistribution,
    required super.registrationTrend,
  });

  factory FarmerMetricsModel.fromJson(Map<String, dynamic> json) {
    return FarmerMetricsModel(
      totalFarmers: json['totalFarmers'] as int,
      newFarmersThisPeriod: json['newFarmersThisPeriod'] as int,
      genderDistribution: GenderDistribution(
        maleCount: json['genderDistribution']['male'] as int,
        femaleCount: json['genderDistribution']['female'] as int,
      ),
      ageDistribution: AgeDistribution(
        age18to25: json['ageDistribution']['age18to25'] as int,
        age26to35: json['ageDistribution']['age26to35'] as int,
        age36to45: json['ageDistribution']['age36to45'] as int,
        age46to55: json['ageDistribution']['age46to55'] as int,
        age56to65: json['ageDistribution']['age56to65'] as int,
        age65Plus: json['ageDistribution']['age65Plus'] as int,
      ),
      geographicDistribution: GeographicDistribution(
        regionBreakdown: Map<String, int>.from(json['geographicDistribution']['byRegion'] as Map),
        districtBreakdown: Map<String, int>.from(json['geographicDistribution']['byDistrict'] as Map),
        wardBreakdown: Map<String, int>.from(json['geographicDistribution']['byWard'] as Map),
        villageBreakdown: Map<String, int>.from(json['geographicDistribution']['byVillage'] as Map),
      ),
      farmersWithAppAccess: json['farmersWithAppAccess'] as int,
      creditScoreDistribution: CreditScoreDistribution(
        range0to300: json['creditScoreDistribution']['score0to300'] as int,
        range301to500: json['creditScoreDistribution']['score301to500'] as int,
        range501to700: json['creditScoreDistribution']['score501to700'] as int,
        range701to850: json['creditScoreDistribution']['score701to850'] as int,
      ),
      registrationTrend: (json['registrationTrend'] as List)
          .map((e) => TimeSeriesDataPoint(
                date: DateTime.parse(e['date'] as String),
                value: (e['value'] as num).toDouble(),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFarmers': totalFarmers,
      'newFarmersThisPeriod': newFarmersThisPeriod,
      'genderDistribution': {
        'male': genderDistribution.maleCount,
        'female': genderDistribution.femaleCount,
      },
      'ageDistribution': {
        'age18to25': ageDistribution.age18to25,
        'age26to35': ageDistribution.age26to35,
        'age36to45': ageDistribution.age36to45,
        'age46to55': ageDistribution.age46to55,
        'age56to65': ageDistribution.age56to65,
        'age65Plus': ageDistribution.age65Plus,
      },
      'geographicDistribution': {
        'byRegion': geographicDistribution.regionBreakdown,
        'byDistrict': geographicDistribution.districtBreakdown,
        'byWard': geographicDistribution.wardBreakdown,
        'byVillage': geographicDistribution.villageBreakdown,
      },
      'farmersWithAppAccess': farmersWithAppAccess,
      'creditScoreDistribution': {
        'score0to300': creditScoreDistribution.range0to300,
        'score301to500': creditScoreDistribution.range301to500,
        'score501to700': creditScoreDistribution.range501to700,
        'score701to850': creditScoreDistribution.range701to850,
      },
      'registrationTrend': registrationTrend
          .map((e) => {
                'date': e.date.toIso8601String(),
                'value': e.value,
              })
          .toList(),
    };
  }
}
