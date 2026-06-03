import 'package:equatable/equatable.dart';

class TimeSeriesDataPoint extends Equatable {
  final DateTime date;
  final double value;

  const TimeSeriesDataPoint({
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [date, value];
}
