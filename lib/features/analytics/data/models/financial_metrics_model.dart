import '../../domain/entities/financial_metrics.dart';
import '../../domain/entities/loan_metrics.dart';
import '../../domain/entities/insurance_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';

class FinancialMetricsModel extends FinancialMetrics {
  const FinancialMetricsModel({
    required super.totalMilkPayments,
    required super.averagePricePerLiter,
    required super.paymentTrend,
    required super.loanMetrics,
    required super.insuranceMetrics,
    required super.totalRevenue,
    required super.revenueBreakdown,
  });

  factory FinancialMetricsModel.fromJson(Map<String, dynamic> json) {
    return FinancialMetricsModel(
      totalMilkPayments: (json['totalMilkPayments'] as num).toDouble(),
      averagePricePerLiter: (json['averagePricePerLiter'] as num).toDouble(),
      paymentTrend: (json['paymentTrend'] as List)
          .map((e) => TimeSeriesDataPoint(
                date: DateTime.parse(e['date'] as String),
                value: (e['value'] as num).toDouble(),
              ))
          .toList(),
      loanMetrics: LoanMetrics(
        totalDisbursed: (json['loanMetrics']['totalDisbursed'] as num).toDouble(),
        totalOutstanding: (json['loanMetrics']['totalOutstanding'] as num).toDouble(),
        repaymentRate: (json['loanMetrics']['repaymentRate'] as num).toDouble(),
        defaultRate: (json['loanMetrics']['defaultRate'] as num).toDouble(),
        activeLoanCount: json['loanMetrics']['activeLoanCount'] as int,
        completedLoanCount: json['loanMetrics']['completedLoanCount'] as int,
        defaultedLoanCount: json['loanMetrics']['defaultedLoanCount'] as int? ?? 0,
      ),
      insuranceMetrics: InsuranceMetrics(
        activePolicies: json['insuranceMetrics']['activePolicies'] as int,
        totalPremiumCollected: (json['insuranceMetrics']['totalPremiumCollected'] as num).toDouble(),
        coveragePercentage: (json['insuranceMetrics']['coveragePercentage'] as num).toDouble(),
        overdueCount: json['insuranceMetrics']['overdueCount'] as int,
        outstandingPremium: (json['insuranceMetrics']['outstandingPremium'] as num).toDouble(),
        totalCattleCovered: json['insuranceMetrics']['totalCattleCovered'] as int? ?? 0,
        totalCattleInSystem: json['insuranceMetrics']['totalCattleInSystem'] as int? ?? 0,
      ),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      revenueBreakdown: Map<String, double>.from(
        (json['revenueBreakdown'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMilkPayments': totalMilkPayments,
      'averagePricePerLiter': averagePricePerLiter,
      'paymentTrend': paymentTrend
          .map((e) => {
                'date': e.date.toIso8601String(),
                'value': e.value,
              })
          .toList(),
      'loanMetrics': {
        'totalDisbursed': loanMetrics.totalDisbursed,
        'totalOutstanding': loanMetrics.totalOutstanding,
        'repaymentRate': loanMetrics.repaymentRate,
        'defaultRate': loanMetrics.defaultRate,
        'activeLoanCount': loanMetrics.activeLoanCount,
        'completedLoanCount': loanMetrics.completedLoanCount,
        'defaultedLoanCount': loanMetrics.defaultedLoanCount,
      },
      'insuranceMetrics': {
        'activePolicies': insuranceMetrics.activePolicies,
        'totalPremiumCollected': insuranceMetrics.totalPremiumCollected,
        'coveragePercentage': insuranceMetrics.coveragePercentage,
        'overdueCount': insuranceMetrics.overdueCount,
        'outstandingPremium': insuranceMetrics.outstandingPremium,
        'totalCattleCovered': insuranceMetrics.totalCattleCovered,
        'totalCattleInSystem': insuranceMetrics.totalCattleInSystem,
      },
      'totalRevenue': totalRevenue,
      'revenueBreakdown': revenueBreakdown,
    };
  }
}
