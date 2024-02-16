import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel {
  final String notification;
  final Timestamp createdAt;

  NotificationsModel({
    required this.notification,
    required this.createdAt,
  });

  NotificationsModel copyWith({
    String? notification,
    Timestamp? createdAt,
  }) {
    return NotificationsModel(
      notification: notification ?? this.notification,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notification': notification,
      'createdAt': createdAt,
    };
  }

  factory NotificationsModel.fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
      notification: map['notification'] ?? "",
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  @override
  bool operator ==(covariant NotificationsModel other) {
    if (identical(this, other)) return true;

    return other.notification == notification && other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return notification.hashCode ^ createdAt.hashCode;
  }
}
