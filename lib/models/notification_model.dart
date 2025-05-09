import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String userId; // A quien va dirigida la notificación
  final String message;
  final String type; // ej. 'LAB_RESULT_READY', 'APPOINTMENT_REMINDER'
  final String? relatedEntityId; // ej. ID de la orden de laboratorio, ID de la cita
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      relatedEntityId: json['related_entity_id'] as String?,
      isRead: (json['is_read'] == 1 || json['is_read'] == true), // Adaptar según el backend devuelva 0/1 o true/false
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'user_id': userId,
      'message': message,
      'type': type,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
    };
  }
}