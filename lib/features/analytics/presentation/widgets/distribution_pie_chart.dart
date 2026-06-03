import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Distribution Pie Chart widget for displaying categorical distributions (Task 17.3)
/// 
/// Displays pie chart with legend, percentages, and tap-to-highlight functionality.
class DistributionPieChart extends StatefulWidget {
  final Map<String, double> distribution;
  final String title;
  final List<Color>? colors;

  const DistributionPieChart({
    super.key,
    required this.distribution,
    required this.title,
    this.colors,
  });

  @override
  State<DistributionPieChart> createState() => _DistributionPieChartState();
}

class _DistributionPieChartState extends State<DistributionPieChart> {
  int? touchedIndex;

  static const List<Color> _defaultColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF9800), // Orange
    Color(0xFF795548), // Brown
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.distribution.isEmpty) {
      return _buildEmptyState(context);
    }

    final total = widget.distribution.values.reduce((a, b) => a + b);
    final entries = widget.distribution.entries.toList();

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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = null;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildSections(entries, total),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildLegend(context, entries, total),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    final colors = widget.colors ?? _defaultColors;

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final percentage = (data.value / total) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildLegend(
    BuildContext context,
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    final colors = widget.colors ?? _defaultColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final percentage = (data.value / total) * 100;
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: touchedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% (${_formatNumber(data.value)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
              height: 200,
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

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
