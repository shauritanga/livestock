import 'package:equatable/equatable.dart';

/// Represents a date range for filtering analytics data
class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Duration of the date range
  Duration get duration => endDate.difference(startDate);

  /// Number of days in the range
  int get days => duration.inDays;

  /// Check if a date falls within this range
  bool contains(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate) ||
        date.isAtSameMomentAs(startDate) ||
        date.isAtSameMomentAs(endDate);
  }

  @override
  List<Object?> get props => [startDate, endDate];

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
