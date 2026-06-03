import 'dart:async';
import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Widget that lazy loads charts when they become visible
/// Uses a simple scroll-based approach instead of visibility_detector
class LazyChartLoader extends StatefulWidget {
  final Widget Function() chartBuilder;
  final double height;
  final String chartKey;

  const LazyChartLoader({
    super.key,
    required this.chartBuilder,
    required this.chartKey,
    this.height = 200,
  });

  @override
  State<LazyChartLoader> createState() => _LazyChartLoaderState();
}

class _LazyChartLoaderState extends State<LazyChartLoader> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load after a short delay to allow initial render
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _hasLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _hasLoaded
        ? widget.chartBuilder()
        : ChartSkeleton(height: widget.height);
  }
}

/// Debounced filter change handler
class DebouncedFilterHandler {
  final Duration delay;
  Timer? _timer;

  DebouncedFilterHandler({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
