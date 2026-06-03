import '../../domain/entities/time_series_data_point.dart';

/// Service for sampling large datasets for chart rendering
class DataSamplingService {
  /// Sample time series data to reduce points for rendering
  /// Uses Largest-Triangle-Three-Buckets (LTTB) algorithm
  static List<TimeSeriesDataPoint> sampleTimeSeries(
    List<TimeSeriesDataPoint> data,
    int targetPoints,
  ) {
    if (data.length <= targetPoints) {
      return data;
    }

    final sampled = <TimeSeriesDataPoint>[];
    
    // Always include first point
    sampled.add(data.first);

    // Calculate bucket size
    final bucketSize = (data.length - 2) / (targetPoints - 2);

    // Always include last point
    var a = 0; // Initially a is the first point in the triangle

    for (var i = 0; i < targetPoints - 2; i++) {
      // Calculate point average for next bucket
      var avgX = 0.0;
      var avgY = 0.0;
      
      final avgRangeStart = ((i + 1) * bucketSize).floor() + 1;
      final avgRangeEnd = ((i + 2) * bucketSize).floor() + 1;
      final avgRangeLength = avgRangeEnd - avgRangeStart;

      for (var j = avgRangeStart; j < avgRangeEnd; j++) {
        if (j < data.length) {
          avgX += data[j].date.millisecondsSinceEpoch.toDouble();
          avgY += data[j].value;
        }
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      // Get the range for this bucket
      final rangeOffs = (i * bucketSize).floor() + 1;
      final rangeTo = ((i + 1) * bucketSize).floor() + 1;

      // Point a
      final pointAX = data[a].date.millisecondsSinceEpoch.toDouble();
      final pointAY = data[a].value;

      var maxArea = -1.0;
      var maxAreaPoint = 0;

      for (var j = rangeOffs; j < rangeTo; j++) {
        if (j < data.length) {
          // Calculate triangle area
          final area = ((pointAX - avgX) * (data[j].value - pointAY) -
                  (pointAX - data[j].date.millisecondsSinceEpoch) *
                      (avgY - pointAY))
              .abs();

          if (area > maxArea) {
            maxArea = area;
            maxAreaPoint = j;
          }
        }
      }

      sampled.add(data[maxAreaPoint]);
      a = maxAreaPoint;
    }

    // Always include last point
    sampled.add(data.last);

    return sampled;
  }

  /// Simple downsampling by taking every nth point
  static List<TimeSeriesDataPoint> simpleDownsample(
    List<TimeSeriesDataPoint> data,
    int targetPoints,
  ) {
    if (data.length <= targetPoints) {
      return data;
    }

    final step = data.length / targetPoints;
    final sampled = <TimeSeriesDataPoint>[];

    for (var i = 0; i < targetPoints; i++) {
      final index = (i * step).floor();
      if (index < data.length) {
        sampled.add(data[index]);
      }
    }

    return sampled;
  }

  /// Determine if data needs sampling based on size
  static bool needsSampling(int dataSize, {int threshold = 100}) {
    return dataSize > threshold;
  }

  /// Get optimal target points based on screen width
  static int getOptimalTargetPoints(double screenWidth) {
    // Aim for roughly 1 point per 5 pixels
    return (screenWidth / 5).ceil().clamp(50, 200);
  }
}
