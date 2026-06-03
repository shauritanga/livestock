import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.type,
    required super.severity,
    required super.title,
    required super.message,
    required super.metadata,
    required super.createdAt,
    required super.isRead,
    super.actionUrl,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      type: AlertType.values.firstWhere((e) => e.name == data['type']),
      severity: AlertSeverity.values.firstWhere((e) => e.name == data['severity']),
      title: data['title'] as String,
      message: data['message'] as String,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool,
      actionUrl: data['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'message': message,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      if (actionUrl != null) 'actionUrl': actionUrl,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: AlertType.values.firstWhere((e) => e.name == json['type']),
      severity: AlertSeverity.values.firstWhere((e) => e.name == json['severity']),
      title: json['title'] as String,
      message: json['message'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'message': message,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      if (actionUrl != null) 'actionUrl': actionUrl,
    };
  }
}
