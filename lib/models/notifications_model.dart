class NotificationsModel {
  final String notification;
  final String feedID;
  final String to_userID;
  final String userID;
  final String notification_type;
  final String dashID;
  final String sttID;
  final bool seen;
  final String? createdAt;
  final int? id;

  NotificationsModel({
    required this.notification,
    this.createdAt,
    required this.feedID,
    required this.notification_type,
    required this.to_userID,
    required this.sttID,
    required this.dashID,
    required this.userID,
    required this.seen,
    this.id,
  });

  NotificationsModel copyWith({
    String? notification,
    String? userID,
    String? feedID,
    String? to_userID,
    String? notification_type,
    String? sttID,
    String? dashID,
    bool? seen,
  }) {
    return NotificationsModel(
      notification: notification ?? this.notification,
      to_userID: to_userID ?? this.to_userID,
      userID: userID ?? this.userID,
      feedID: feedID ?? this.feedID,
      notification_type: notification_type ?? this.notification_type,
      sttID: sttID ?? this.sttID,
      dashID: dashID ?? this.dashID,
      seen: seen ?? this.seen,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notification': notification,
      'feedID': feedID,
      'to_userID': to_userID,
      'userID': userID,
      'notification_type': notification_type,
      'sttID': sttID,
      'dashID': dashID,
      'seen': seen,
    };
  }

  factory NotificationsModel.fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
        notification: map['notification'] ?? "",
        createdAt: map['createdAt'],
        to_userID: map['to_userID'] ?? "",
        userID: map['userID'] ?? "",
        feedID: map['feedID'] ?? "",
        notification_type: map['notification_type'] ?? "",
        sttID: map['sttID'] ?? "",
        seen: map['seen'] ?? true,
        id: map['notificationID'] ?? 0,
        dashID: map['dashID'] ?? "");
  }
}
