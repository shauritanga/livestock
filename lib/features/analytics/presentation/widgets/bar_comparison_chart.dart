import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart data model
class BarChartDataItem {
  final String label;
  final double value;
  final double? comparisonValue;

  const BarChartDataItem({
    required this.label,
    required this.value,
    this.comparisonValue,
  });
}

/// Bar Comparison Chart widget for displaying comparative data (Task 17.4)
/// 
/// Displays bar chart with optional grouped bars for comparisons and value labels.
class BarComparisonChart extends StatefulWidget {
  final List<BarChartDataItem> data;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color primaryColor;
  final Color? comparisonColor;

  const BarComparisonChart({
    super.key,
    required this.data,
    required this.title,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.primaryColor = Colors.blue,
    this.comparisonColor,
  });

  @override
  State<BarComparisonChart> createState() => _BarComparisonChartState();
}

class _BarComparisonChartState extends State<BarComparisonChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    final hasComparison = widget.data.any((item) => item.comparisonValue != null);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                _buildChartData(hasComparison),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            if (hasComparison) ...[
              const SizedBox(height: 8),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(bool hasComparison) {
    final maxValue = _getMaxValue();
    final interval = _calculateInterval(maxValue);

    return BarChartData(
      maxY: maxValue * 1.1,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final item = widget.data[groupIndex];
            final value = rodIndex == 0 ? item.value : item.comparisonValue ?? 0;
            return BarTooltipItem(
              '${item.label}\n${_formatNumber(value)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = null;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
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
          axisNameWidget: widget.xAxisLabel.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.xAxisLabel,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              : null,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.data.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.data[index].label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: widget.yAxisLabel.isNotEmpty
              ? Text(
                  widget.yAxisLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              : null,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatNumber(value),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      barGroups: _buildBarGroups(hasComparison),
    );
  }

  List<BarChartGroupData> _buildBarGroups(bool hasComparison) {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;

      if (hasComparison && item.comparisonValue != null) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.value,
              color: widget.primaryColor,
              width: isTouched ? 18 : 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: item.comparisonValue!,
              color: widget.comparisonColor ?? Colors.orange,
              width: isTouched ? 18 : 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 4,
        );
      } else {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.value,
              color: widget.primaryColor,
              width: isTouched ? 24 : 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, 'Current', widget.primaryColor),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          'Comparison',
          widget.comparisonColor ?? Colors.orange,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (final item in widget.data) {
      if (item.value > max) max = item.value;
      if (item.comparisonValue != null && item.comparisonValue! > max) {
        max = item.comparisonValue!;
      }
    }
    return max;
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    return (maxValue / 5).ceilToDouble();
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
