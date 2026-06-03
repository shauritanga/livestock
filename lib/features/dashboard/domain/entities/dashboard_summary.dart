import 'package:equatable/equatable.dart';

/// Dashboard summary entity containing today's collection metrics
class DashboardSummary extends Equatable {
  final double totalLiters;
  final int farmerCount;
  final double totalPayment;
  final DateTime date;

  const DashboardSummary({
    required this.totalLiters,
    required this.farmerCount,
    required this.totalPayment,
    required this.date,
  });

  @override
  List<Object?> get props => [
        totalLiters,
        farmerCount,
        totalPayment,
        date,
      ];

  DashboardSummary copyWith({
    double? totalLiters,
    int? farmerCount,
    double? totalPayment,
    DateTime? date,
  }) {
    return DashboardSummary(
      totalLiters: totalLiters ?? this.totalLiters,
      farmerCount: farmerCount ?? this.farmerCount,
      totalPayment: totalPayment ?? this.totalPayment,
      date: date ?? this.date,
    );
  }
}
