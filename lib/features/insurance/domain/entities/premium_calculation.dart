import 'package:equatable/equatable.dart';

/// Represents the result of a premium calculation for insurance enrollment
class PremiumCalculation extends Equatable {
  final List<CattlePremium> cattlePremiums;
  final double totalAnnualPremium;
  final double monthlyInstallment;
  final double quarterlyInstallment;

  const PremiumCalculation({
    required this.cattlePremiums,
    required this.totalAnnualPremium,
    required this.monthlyInstallment,
    required this.quarterlyInstallment,
  });

  @override
  List<Object?> get props => [
        totalAnnualPremium,
        cattlePremiums,
      ];

  /// Creates a copy of this calculation with the given fields replaced
  PremiumCalculation copyWith({
    List<CattlePremium>? cattlePremiums,
    double? totalAnnualPremium,
    double? monthlyInstallment,
    double? quarterlyInstallment,
  }) {
    return PremiumCalculation(
      cattlePremiums: cattlePremiums ?? this.cattlePremiums,
      totalAnnualPremium: totalAnnualPremium ?? this.totalAnnualPremium,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      quarterlyInstallment: quarterlyInstallment ?? this.quarterlyInstallment,
    );
  }

  /// Gets the number of cattle being insured
  int get cattleCount => cattlePremiums.length;

  /// Gets the average premium per cattle
  double get averagePremiumPerCattle {
    if (cattlePremiums.isEmpty) return 0;
    return totalAnnualPremium / cattlePremiums.length;
  }
}

/// Represents the premium calculation for an individual cattle
class CattlePremium extends Equatable {
  final String cattleId;
  final String cattleName;
  final double premium;
  final String rateCategory;

  const CattlePremium({
    required this.cattleId,
    required this.cattleName,
    required this.premium,
    required this.rateCategory,
  });

  @override
  List<Object?> get props => [
        cattleId,
        premium,
      ];

  /// Creates a copy of this cattle premium with the given fields replaced
  CattlePremium copyWith({
    String? cattleId,
    String? cattleName,
    double? premium,
    String? rateCategory,
  }) {
    return CattlePremium(
      cattleId: cattleId ?? this.cattleId,
      cattleName: cattleName ?? this.cattleName,
      premium: premium ?? this.premium,
      rateCategory: rateCategory ?? this.rateCategory,
    );
  }
}
