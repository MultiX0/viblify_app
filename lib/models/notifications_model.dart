import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel {
  final String notification;
  final String feedID;
  final String to_userID;
  final String userID;
  final String notification_type;
  final String sttID;
  final Timestamp createdAt;

  NotificationsModel({
    required this.notification,
    required this.createdAt,
    required this.feedID,
    required this.notification_type,
    required this.to_userID,
    required this.sttID,
    required this.userID,
  });

  NotificationsModel copyWith({
    String? notification,
    String? userID,
    String? feedID,
    String? to_userID,
    String? notification_type,
    String? sttID,
    Timestamp? createdAt,
  }) {
    return NotificationsModel(
      notification: notification ?? this.notification,
      createdAt: createdAt ?? this.createdAt,
      to_userID: to_userID ?? this.to_userID,
      userID: userID ?? this.userID,
      feedID: feedID ?? this.feedID,
      notification_type: notification_type ?? this.notification_type,
      sttID: sttID ?? this.sttID,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notification': notification,
      'createdAt': createdAt,
      'feedID': feedID,
      'to_userID': to_userID,
      'userID': userID,
      'notification_type': notification_type,
      'sttID': sttID,
    };
  }

  factory NotificationsModel.fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
      notification: map['notification'] ?? "",
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      to_userID: map['to_userID'] ?? "",
      userID: map['userID'] ?? "",
      feedID: map['feedID'] ?? "",
      notification_type: map['notification_type'] ?? "",
      sttID: map['sttID'] ?? "",
    );
  }
}
