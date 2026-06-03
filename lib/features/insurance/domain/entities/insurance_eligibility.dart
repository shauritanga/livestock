import 'package:equatable/equatable.dart';

/// Represents the insurance eligibility status for a farmer
/// Used to verify if a farmer can apply for loans
class InsuranceEligibility extends Equatable {
  final bool isEligible;
  final String? reason;
  final List<String>? uncoveredCattleIds;

  const InsuranceEligibility({
    required this.isEligible,
    this.reason,
    this.uncoveredCattleIds,
  });

  @override
  List<Object?> get props => [
        isEligible,
        reason,
        uncoveredCattleIds,
      ];

  /// Creates a copy of this eligibility with the given fields replaced
  InsuranceEligibility copyWith({
    bool? isEligible,
    String? reason,
    List<String>? uncoveredCattleIds,
  }) {
    return InsuranceEligibility(
      isEligible: isEligible ?? this.isEligible,
      reason: reason ?? this.reason,
      uncoveredCattleIds: uncoveredCattleIds ?? this.uncoveredCattleIds,
    );
  }

  /// Gets the number of uncovered cattle
  int get uncoveredCattleCount => uncoveredCattleIds?.length ?? 0;

  /// Checks if there are uncovered cattle
  bool get hasUncoveredCattle =>
      uncoveredCattleIds != null && uncoveredCattleIds!.isNotEmpty;

  /// Factory constructor for eligible status
  factory InsuranceEligibility.eligible() {
    return const InsuranceEligibility(isEligible: true);
  }

  /// Factory constructor for no active policy
  factory InsuranceEligibility.noActivePolicy() {
    return const InsuranceEligibility(
      isEligible: false,
      reason: 'No active insurance policy',
    );
  }

  /// Factory constructor for uncovered cattle
  factory InsuranceEligibility.uncoveredCattle(List<String> cattleIds) {
    return InsuranceEligibility(
      isEligible: false,
      reason: '${cattleIds.length} productive cattle not insured',
      uncoveredCattleIds: cattleIds,
    );
  }

  /// Factory constructor for overdue premiums
  factory InsuranceEligibility.overduePremiums() {
    return const InsuranceEligibility(
      isEligible: false,
      reason: 'Overdue premium payments',
    );
  }
}
