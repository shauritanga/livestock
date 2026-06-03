import 'package:equatable/equatable.dart';

/// Alert type enumeration
enum AlertType {
  productionDrop,
  lowStock,
  loanDefault,
  insuranceLapse,
  farmerEngagement,
  qualityConcern,
}

/// Alert severity enumeration
enum AlertSeverity {
  critical,
  warning,
  informational,
}

/// Alert entity for critical metrics and anomalies
class Alert extends Equatable {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.metadata,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  /// Alert age in hours
  int get ageInHours => DateTime.now().difference(createdAt).inHours;

  /// Is alert recent (less than 24 hours old)
  bool get isRecent => ageInHours < 24;

  /// Is alert urgent (critical and recent)
  bool get isUrgent => severity == AlertSeverity.critical && isRecent;

  /// Severity color (for UI)
  String get severityColor {
    switch (severity) {
      case AlertSeverity.critical:
        return 'red';
      case AlertSeverity.warning:
        return 'orange';
      case AlertSeverity.informational:
        return 'blue';
    }
  }

  /// Type icon (for UI)
  String get typeIcon {
    switch (type) {
      case AlertType.productionDrop:
        return 'trending_down';
      case AlertType.lowStock:
        return 'inventory';
      case AlertType.loanDefault:
        return 'account_balance';
      case AlertType.insuranceLapse:
        return 'shield';
      case AlertType.farmerEngagement:
        return 'people';
      case AlertType.qualityConcern:
        return 'warning';
    }
  }

  /// Type label
  String get typeLabel {
    switch (type) {
      case AlertType.productionDrop:
        return 'Production Drop';
      case AlertType.lowStock:
        return 'Low Stock';
      case AlertType.loanDefault:
        return 'Loan Default';
      case AlertType.insuranceLapse:
        return 'Insurance Lapse';
      case AlertType.farmerEngagement:
        return 'Farmer Engagement';
      case AlertType.qualityConcern:
        return 'Quality Concern';
    }
  }

  /// Severity label
  String get severityLabel {
    switch (severity) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.informational:
        return 'Info';
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        severity,
        title,
        message,
        metadata,
        createdAt,
        isRead,
        actionUrl,
      ];

  Alert copyWith({
    String? id,
    AlertType? type,
    AlertSeverity? severity,
    String? title,
    String? message,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Mark alert as read
  Alert markAsRead() {
    return copyWith(isRead: true);
  }
}
