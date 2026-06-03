import 'package:flutter/material.dart';

/// Geographic Heat Map widget for displaying regional data (Task 17.5)
/// 
/// Displays regions with color gradient based on values and tap-to-show-details.
class GeographicHeatMap extends StatefulWidget {
  final Map<String, double> regionData;
  final String title;
  final Color minColor;
  final Color maxColor;
  final Function(String region, double value)? onRegionTap;

  const GeographicHeatMap({
    super.key,
    required this.regionData,
    required this.title,
    this.minColor = const Color(0xFFE3F2FD),
    this.maxColor = const Color(0xFF1976D2),
    this.onRegionTap,
  });

  @override
  State<GeographicHeatMap> createState() => _GeographicHeatMapState();
}

class _GeographicHeatMapState extends State<GeographicHeatMap> {
  String? selectedRegion;

  @override
  Widget build(BuildContext context) {
    if (widget.regionData.isEmpty) {
      return _buildEmptyState(context);
    }

    final minValue = widget.regionData.values.reduce((a, b) => a < b ? a : b);
    final maxValue = widget.regionData.values.reduce((a, b) => a > b ? a : b);

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
            _buildColorScale(context, minValue, maxValue),
            const SizedBox(height: 16),
            _buildRegionGrid(context, minValue, maxValue),
          ],
        ),
      ),
    );
  }

  Widget _buildColorScale(BuildContext context, double minValue, double maxValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.minColor, widget.maxColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatNumber(minValue),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              _formatNumber(maxValue),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionGrid(BuildContext context, double minValue, double maxValue) {
    final sortedEntries = widget.regionData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedEntries.map((entry) {
        final region = entry.key;
        final value = entry.value;
        final isSelected = selectedRegion == region;

        return _buildRegionCard(
          context,
          region,
          value,
          _getColorForValue(value, minValue, maxValue),
          isSelected,
        );
      }).toList(),
    );
  }

  Widget _buildRegionCard(
    BuildContext context,
    String region,
    double value,
    Color color,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedRegion = isSelected ? null : region;
        });
        widget.onRegionTap?.call(region, value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              region,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: _getTextColor(color),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNumber(value),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTextColor(color).withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
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

  Color _getColorForValue(double value, double minValue, double maxValue) {
    if (maxValue == minValue) {
      return widget.maxColor;
    }

    final normalizedValue = (value - minValue) / (maxValue - minValue);
    
    return Color.lerp(widget.minColor, widget.maxColor, normalizedValue)!;
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be dark or light
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
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
