import 'package:equatable/equatable.dart';

/// Insurance performance metrics
class InsuranceMetrics extends Equatable {
  final int activePolicies;
  final double totalPremiumCollected;
  final double coveragePercentage;
  final int overdueCount;
  final double outstandingPremium;
  final int totalCattleCovered;
  final int totalCattleInSystem;

  const InsuranceMetrics({
    required this.activePolicies,
    required this.totalPremiumCollected,
    required this.coveragePercentage,
    required this.overdueCount,
    required this.outstandingPremium,
    required this.totalCattleCovered,
    required this.totalCattleInSystem,
  });

  /// Policies in good standing (not overdue)
  int get policiesInGoodStanding => activePolicies - overdueCount;

  /// Overdue percentage
  double get overduePercentage =>
      activePolicies > 0 ? (overdueCount / activePolicies) * 100 : 0;

  /// Average premium per policy
  double get averagePremiumPerPolicy =>
      activePolicies > 0 ? totalPremiumCollected / activePolicies : 0;

  /// Average cattle per policy
  double get averageCattlePerPolicy =>
      activePolicies > 0 ? totalCattleCovered / activePolicies : 0;

  /// Collection rate (collected vs total due)
  double get collectionRate {
    final totalDue = totalPremiumCollected + outstandingPremium;
    return totalDue > 0 ? (totalPremiumCollected / totalDue) * 100 : 0;
  }

  /// Coverage status
  String get coverageStatus {
    if (coveragePercentage >= 80) return 'Excellent';
    if (coveragePercentage >= 60) return 'Good';
    if (coveragePercentage >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  List<Object?> get props => [
        activePolicies,
        totalPremiumCollected,
        coveragePercentage,
        overdueCount,
        outstandingPremium,
        totalCattleCovered,
        totalCattleInSystem,
      ];

  InsuranceMetrics copyWith({
    int? activePolicies,
    double? totalPremiumCollected,
    double? coveragePercentage,
    int? overdueCount,
    double? outstandingPremium,
    int? totalCattleCovered,
    int? totalCattleInSystem,
  }) {
    return InsuranceMetrics(
      activePolicies: activePolicies ?? this.activePolicies,
      totalPremiumCollected:
          totalPremiumCollected ?? this.totalPremiumCollected,
      coveragePercentage: coveragePercentage ?? this.coveragePercentage,
      overdueCount: overdueCount ?? this.overdueCount,
      outstandingPremium: outstandingPremium ?? this.outstandingPremium,
      totalCattleCovered: totalCattleCovered ?? this.totalCattleCovered,
      totalCattleInSystem: totalCattleInSystem ?? this.totalCattleInSystem,
    );
  }
}
