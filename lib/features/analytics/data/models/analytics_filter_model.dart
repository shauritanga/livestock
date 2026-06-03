import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/entities/date_range.dart';

class AnalyticsFilterModel extends AnalyticsFilter {
  const AnalyticsFilterModel({
    required super.dateRange,
    super.cooperativeIds,
    super.collectionCenterIds,
    super.region,
    super.district,
    super.ward,
    super.village,
  });

  factory AnalyticsFilterModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsFilterModel(
      dateRange: DateRange(
        startDate: DateTime.parse(json['dateRange']['startDate'] as String),
        endDate: DateTime.parse(json['dateRange']['endDate'] as String),
      ),
      cooperativeIds: json['cooperativeIds'] != null
          ? List<String>.from(json['cooperativeIds'] as List)
          : null,
      collectionCenterIds: json['collectionCenterIds'] != null
          ? List<String>.from(json['collectionCenterIds'] as List)
          : null,
      region: json['region'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateRange': {
        'startDate': dateRange.startDate.toIso8601String(),
        'endDate': dateRange.endDate.toIso8601String(),
      },
      if (cooperativeIds != null) 'cooperativeIds': cooperativeIds,
      if (collectionCenterIds != null)
        'collectionCenterIds': collectionCenterIds,
      if (region != null) 'region': region,
      if (district != null) 'district': district,
      if (ward != null) 'ward': ward,
      if (village != null) 'village': village,
    };
  }

  String generateCacheKey() {
    final jsonString = jsonEncode(toJson());
    final bytes = utf8.encode(jsonString);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
