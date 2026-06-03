import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/loan_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/insurance_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';

/// Comprehensive financial performance metrics
class FinancialMetrics extends Equatable {
  final double totalMilkPayments;
  final double averagePricePerLiter;
  final List<TimeSeriesDataPoint> paymentTrend;
  final LoanMetrics loanMetrics;
  final InsuranceMetrics insuranceMetrics;
  final double totalRevenue;
  final Map<String, double> revenueBreakdown;

  const FinancialMetrics({
    required this.totalMilkPayments,
    required this.averagePricePerLiter,
    required this.paymentTrend,
    required this.loanMetrics,
    required this.insuranceMetrics,
    required this.totalRevenue,
    required this.revenueBreakdown,
  });

  /// Milk payments as percentage of total revenue
  double get milkPaymentsPercentage =>
      totalRevenue > 0 ? (totalMilkPayments / totalRevenue) * 100 : 0;

  /// Loan interest revenue
  double get loanInterestRevenue =>
      revenueBreakdown['loan_interest'] ?? revenueBreakdown['loanInterest'] ?? 0;

  /// Insurance premium revenue
  double get insurancePremiumRevenue =>
      revenueBreakdown['insurance_premium'] ??
      revenueBreakdown['insurancePremium'] ??
      0;

  /// Other revenue
  double get otherRevenue =>
      revenueBreakdown['other'] ?? revenueBreakdown['others'] ?? 0;

  /// Revenue diversity score (0-100, higher is better)
  double get revenueDiversityScore {
    if (totalRevenue == 0) return 0;

    final milkShare = milkPaymentsPercentage / 100;
    final loanShare = loanInterestRevenue / totalRevenue;
    final insuranceShare = insurancePremiumRevenue / totalRevenue;
    final otherShare = otherRevenue / totalRevenue;

    // Calculate Herfindahl-Hirschman Index (HHI) and convert to diversity score
    final hhi = (milkShare * milkShare) +
        (loanShare * loanShare) +
        (insuranceShare * insuranceShare) +
        (otherShare * otherShare);

    // Convert HHI to diversity score (0-100, where 100 is perfectly diversified)
    return (1 - hhi) * 100;
  }

  /// Financial health status
  String get financialHealthStatus {
    final loanRisk = loanMetrics.riskLevel;
    final insuranceCoverage = insuranceMetrics.coverageStatus;
    final diversity = revenueDiversityScore;

    if (loanRisk == 'Low' &&
        (insuranceCoverage == 'Excellent' || insuranceCoverage == 'Good') &&
        diversity > 50) {
      return 'Excellent';
    } else if (loanRisk == 'Medium' || diversity > 30) {
      return 'Good';
    } else if (loanRisk == 'High') {
      return 'Fair';
    }
    return 'Poor';
  }

  /// Get revenue breakdown as percentages
  Map<String, double> get revenueBreakdownPercentages {
    if (totalRevenue == 0) return {};

    return {
      'Milk Payments': milkPaymentsPercentage,
      'Loan Interest': (loanInterestRevenue / totalRevenue) * 100,
      'Insurance Premium': (insurancePremiumRevenue / totalRevenue) * 100,
      'Other': (otherRevenue / totalRevenue) * 100,
    };
  }

  @override
  List<Object?> get props => [
        totalMilkPayments,
        averagePricePerLiter,
        paymentTrend,
        loanMetrics,
        insuranceMetrics,
        totalRevenue,
        revenueBreakdown,
      ];

  FinancialMetrics copyWith({
    double? totalMilkPayments,
    double? averagePricePerLiter,
    List<TimeSeriesDataPoint>? paymentTrend,
    LoanMetrics? loanMetrics,
    InsuranceMetrics? insuranceMetrics,
    double? totalRevenue,
    Map<String, double>? revenueBreakdown,
  }) {
    return FinancialMetrics(
      totalMilkPayments: totalMilkPayments ?? this.totalMilkPayments,
      averagePricePerLiter: averagePricePerLiter ?? this.averagePricePerLiter,
      paymentTrend: paymentTrend ?? this.paymentTrend,
      loanMetrics: loanMetrics ?? this.loanMetrics,
      insuranceMetrics: insuranceMetrics ?? this.insuranceMetrics,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      revenueBreakdown: revenueBreakdown ?? this.revenueBreakdown,
    );
  }
}
