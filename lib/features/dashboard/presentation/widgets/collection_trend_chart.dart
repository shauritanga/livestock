import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:livestock/features/dashboard/domain/entities/collection_data_point.dart';
import 'package:livestock/features/dashboard/domain/entities/trend_period.dart';
import 'package:intl/intl.dart';

/// Number formatter for displaying liters with thousand separators
final _numberFormat = NumberFormat('#,##0.#', 'en_US');

/// Collection trend chart widget using fl_chart
class CollectionTrendChart extends StatelessWidget {
  final List<CollectionDataPoint> data;
  final TrendPeriod period;
  final Function(TrendPeriod)? onPeriodChanged;

  const CollectionTrendChart({
    super.key,
    required this.data,
    required this.period,
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((point) => point.volumeLiters == 0)) {
      return _buildEmptyState();
    }

    // Calculate total collection for the period
    final totalCollection = data.fold<double>(
      0,
      (sum, point) => sum + point.volumeLiters,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with total and period selector
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Total collection (left side)
              Text(
                '${_numberFormat.format(totalCollection)}L',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Period selector (right side)
              if (onPeriodChanged != null)
                _buildPeriodDropdown(context),
            ],
          ),
        ),
        // Bar chart
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BarChart(
              _buildBarChartData(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return DropdownButton<TrendPeriod>(
      value: period,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, size: 20),
      items: TrendPeriod.values.map((TrendPeriod value) {
        return DropdownMenuItem<TrendPeriod>(
          value: value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getPeriodIcon(value), size: 16),
              const SizedBox(width: 6),
              Text(
                value.getDisplayName(context),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (TrendPeriod? newValue) {
        if (newValue != null && onPeriodChanged != null) {
          onPeriodChanged!(newValue);
        }
      },
    );
  }

  IconData _getPeriodIcon(TrendPeriod period) {
    switch (period) {
      case TrendPeriod.week:
        return Icons.calendar_view_week;
      case TrendPeriod.month:
        return Icons.calendar_month;
      case TrendPeriod.year:
        return Icons.calendar_today;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No collection data available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Find max value for Y axis
    final maxY = data.fold<double>(
      0,
      (max, point) => point.volumeLiters > max ? point.volumeLiters : max,
    );

    // Create bar groups
    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: point.volumeLiters,
            color: primaryColor,
            width: 16,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY * 1.2, // Add 20% padding at top
      minY: 0,
      barGroups: barGroups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY > 0 ? maxY / 5 : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= data.length) return const Text('');
              
              final date = data[value.toInt()].date;
              String label;
              
              switch (period) {
                case TrendPeriod.week:
                  // Show day abbreviations (MO, TU, WE, etc.)
                  label = DateFormat('E').format(date).substring(0, 2).toUpperCase();
                  break;
                case TrendPeriod.month:
                  // Show week numbers (W1, W2, W3, W4)
                  final weekNumber = (value.toInt() + 1);
                  label = 'W$weekNumber';
                  break;
                case TrendPeriod.year:
                  // Show month abbreviations (JAN, FEB, MAR, etc.)
                  label = DateFormat('MMM').format(date).toUpperCase();
                  break;
              }
              
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: maxY > 0 ? maxY / 5 : 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final date = data[groupIndex].date;
            final volume = rod.toY;
            final farmers = data[groupIndex].farmerCount;
            
            String dateLabel;
            switch (period) {
              case TrendPeriod.week:
                dateLabel = DateFormat('EEEE, MMM d').format(date);
                break;
              case TrendPeriod.month:
                dateLabel = 'Week ${groupIndex + 1}';
                break;
              case TrendPeriod.year:
                dateLabel = DateFormat('MMMM yyyy').format(date);
                break;
            }
            
            return BarTooltipItem(
              '$dateLabel\n${volume.toStringAsFixed(1)}L\n$farmers farmers',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }
}
