import 'package:equatable/equatable.dart';

/// Age distribution statistics with age brackets
class AgeDistribution extends Equatable {
  final int age18to25;
  final int age26to35;
  final int age36to45;
  final int age46to55;
  final int age56to65;
  final int age65Plus;

  const AgeDistribution({
    required this.age18to25,
    required this.age26to35,
    required this.age36to45,
    required this.age46to55,
    required this.age56to65,
    required this.age65Plus,
  });

  /// Total count
  int get total =>
      age18to25 + age26to35 + age36to45 + age46to55 + age56to65 + age65Plus;

  /// Get percentage for a specific age bracket
  double getPercentage(String bracket) {
    if (total == 0) return 0;
    
    switch (bracket) {
      case '18-25':
        return (age18to25 / total) * 100;
      case '26-35':
        return (age26to35 / total) * 100;
      case '36-45':
        return (age36to45 / total) * 100;
      case '46-55':
        return (age46to55 / total) * 100;
      case '56-65':
        return (age56to65 / total) * 100;
      case '65+':
        return (age65Plus / total) * 100;
      default:
        return 0;
    }
  }

  /// Get distribution as map
  Map<String, int> toMap() {
    return {
      '18-25': age18to25,
      '26-35': age26to35,
      '36-45': age36to45,
      '46-55': age46to55,
      '56-65': age56to65,
      '65+': age65Plus,
    };
  }

  @override
  List<Object?> get props => [
        age18to25,
        age26to35,
        age36to45,
        age46to55,
        age56to65,
        age65Plus,
      ];

  AgeDistribution copyWith({
    int? age18to25,
    int? age26to35,
    int? age36to45,
    int? age46to55,
    int? age56to65,
    int? age65Plus,
  }) {
    return AgeDistribution(
      age18to25: age18to25 ?? this.age18to25,
      age26to35: age26to35 ?? this.age26to35,
      age36to45: age36to45 ?? this.age36to45,
      age46to55: age46to55 ?? this.age46to55,
      age56to65: age56to65 ?? this.age56to65,
      age65Plus: age65Plus ?? this.age65Plus,
    );
  }
}
