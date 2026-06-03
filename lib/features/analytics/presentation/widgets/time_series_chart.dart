import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';

/// Time Series Chart widget for displaying trend data over time (Task 17.2)
/// 
/// Displays line chart with optional forecast data, zoom/pan gestures, and tooltips.
class TimeSeriesChart extends StatefulWidget {
  final List<TimeSeriesDataPoint> data;
  final String title;
  final String yAxisLabel;
  final Color lineColor;
  final List<TimeSeriesDataPoint>? forecastData;
  final bool showForecast;

  const TimeSeriesChart({
    super.key,
    required this.data,
    required this.title,
    required this.yAxisLabel,
    this.lineColor = Colors.blue,
    this.forecastData,
    this.showForecast = false,
  });

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

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
              height: 250,
              child: LineChart(
                _buildChartData(),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            if (widget.showForecast && widget.forecastData != null) ...[
              const SizedBox(height: 8),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final allData = [...widget.data];
    if (widget.showForecast && widget.forecastData != null) {
      allData.addAll(widget.forecastData!);
    }

    final minY = allData.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxY = allData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChartData(
      minY: minY - padding,
      maxY: maxY + padding,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = _getDateForIndex(spot.x.toInt());
              return LineTooltipItem(
                '${_formatDate(date)}\n${spot.y.toStringAsFixed(1)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: widget.lineColor.withValues(alpha: 0.5),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: widget.lineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            widget.yAxisLabel,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatNumber(value),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              );
            },
          ),
        ),
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
            interval: _calculateInterval(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= allData.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _formatDate(allData[index].date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
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
      lineBarsData: [
        // Actual data line
        LineChartBarData(
          spots: widget.data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList(),
          isCurved: true,
          color: widget.lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: widget.lineColor.withValues(alpha: 0.1),
          ),
        ),
        // Forecast data line (dashed)
        if (widget.showForecast && widget.forecastData != null)
          LineChartBarData(
            spots: widget.forecastData!.asMap().entries.map((entry) {
              final index = widget.data.length + entry.key;
              return FlSpot(index.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: widget.lineColor.withValues(alpha: 0.6),
            barWidth: 3,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: widget.lineColor.withValues(alpha: 0.05),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, 'Actual', widget.lineColor, false),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          'Forecast',
          widget.lineColor.withValues(alpha: 0.6),
          true,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    bool isDashed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: _DashedLinePainter(color),
                )
              : null,
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
              height: 250,
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

  DateTime _getDateForIndex(int index) {
    final allData = [...widget.data];
    if (widget.showForecast && widget.forecastData != null) {
      allData.addAll(widget.forecastData!);
    }
    if (index >= 0 && index < allData.length) {
      return allData[index].date;
    }
    return DateTime.now();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  double _calculateInterval() {
    final dataLength = widget.data.length;
    if (dataLength <= 7) return 1;
    if (dataLength <= 30) return 5;
    return 10;
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
