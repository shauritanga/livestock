import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/milk_production_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/farmer_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/livestock_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/financial_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/inventory_metrics.dart';

/// Comprehensive analytics summary across all categories
class AnalyticsSummary extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final MilkProductionMetrics milkMetrics;
  final FarmerMetrics farmerMetrics;
  final LivestockMetrics livestockMetrics;
  final FinancialMetrics financialMetrics;
  final InventoryMetrics inventoryMetrics;

  const AnalyticsSummary({
    required this.startDate,
    required this.endDate,
    required this.milkMetrics,
    required this.farmerMetrics,
    required this.livestockMetrics,
    required this.financialMetrics,
    required this.inventoryMetrics,
  });

  /// Period duration in days
  int get periodDays => endDate.difference(startDate).inDays + 1;

  /// Key Performance Indicators

  /// Total milk collected (liters)
  double get totalMilkLiters => milkMetrics.totalLiters;

  /// Total farmers
  int get totalFarmers => farmerMetrics.totalFarmers;

  /// Total cattle
  int get totalCattle => livestockMetrics.totalCattle;

  /// Total revenue
  double get totalRevenue => financialMetrics.totalRevenue;

  /// Total inventory value
  double get totalInventoryValue => inventoryMetrics.totalInventoryValue;

  /// Average daily milk production
  double get averageDailyMilkProduction => milkMetrics.averageLitersPerDay;

  /// Farmer growth rate
  double get farmerGrowthRate => farmerMetrics.growthRate;

  /// Lactation rate
  double get lactationRate => livestockMetrics.lactationRate;

  /// Loan repayment rate
  double get loanRepaymentRate => financialMetrics.loanMetrics.repaymentRate;

  /// Insurance coverage percentage
  double get insuranceCoveragePercentage =>
      financialMetrics.insuranceMetrics.coveragePercentage;

  /// Inventory health percentage
  double get inventoryHealthPercentage =>
      inventoryMetrics.stockHealthPercentage;

  /// Overall health score (0-100)
  double get overallHealthScore {
    // Weighted average of key health indicators
    final milkHealth = milkMetrics.qualityGradePercentage; // 20%
    final farmerHealth = farmerMetrics.appAdoptionPercentage; // 15%
    final livestockHealth = livestockMetrics.healthyCattlePercentage; // 20%
    final financialHealth = _financialHealthScore(); // 25%
    final inventoryHealth = inventoryMetrics.stockHealthPercentage; // 20%

    return (milkHealth * 0.20) +
        (farmerHealth * 0.15) +
        (livestockHealth * 0.20) +
        (financialHealth * 0.25) +
        (inventoryHealth * 0.20);
  }

  /// Financial health score (0-100)
  double _financialHealthScore() {
    final repaymentScore = financialMetrics.loanMetrics.repaymentRate;
    final coverageScore = financialMetrics.insuranceMetrics.coveragePercentage;
    final diversityScore = financialMetrics.revenueDiversityScore;

    return (repaymentScore * 0.4) +
        (coverageScore * 0.3) +
        (diversityScore * 0.3);
  }

  /// Overall status based on health score
  String get overallStatus {
    if (overallHealthScore >= 80) return 'Excellent';
    if (overallHealthScore >= 60) return 'Good';
    if (overallHealthScore >= 40) return 'Fair';
    return 'Needs Attention';
  }

  /// Critical alerts count
  int get criticalAlertsCount {
    int count = 0;

    // Check for critical conditions
    if (milkMetrics.qualityDistribution.substandardPercentage > 20) count++;
    if (livestockMetrics.healthyCattlePercentage < 70) count++;
    if (financialMetrics.loanMetrics.defaultRate > 15) count++;
    if (inventoryMetrics.outOfStockPercentage > 15) count++;
    if (farmerMetrics.appAdoptionPercentage < 30) count++;

    return count;
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        milkMetrics,
        farmerMetrics,
        livestockMetrics,
        financialMetrics,
        inventoryMetrics,
      ];

  AnalyticsSummary copyWith({
    DateTime? startDate,
    DateTime? endDate,
    MilkProductionMetrics? milkMetrics,
    FarmerMetrics? farmerMetrics,
    LivestockMetrics? livestockMetrics,
    FinancialMetrics? financialMetrics,
    InventoryMetrics? inventoryMetrics,
  }) {
    return AnalyticsSummary(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      milkMetrics: milkMetrics ?? this.milkMetrics,
      farmerMetrics: farmerMetrics ?? this.farmerMetrics,
      livestockMetrics: livestockMetrics ?? this.livestockMetrics,
      financialMetrics: financialMetrics ?? this.financialMetrics,
      inventoryMetrics: inventoryMetrics ?? this.inventoryMetrics,
    );
  }
}
