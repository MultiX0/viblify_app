import 'package:cloud_firestore/cloud_firestore.dart';

class STT {
  final String userID;
  final String message;
  final String sttID;
  final Timestamp createdAt;
  final bool isShowed;

  STT({
    required this.userID,
    required this.message,
    required this.sttID,
    required this.createdAt,
    required this.isShowed,
  });

  STT copyWith({
    String? userID,
    String? message,
    String? sttID,
    Timestamp? createdAt,
    bool? isShowed,
  }) {
    return STT(
      sttID: sttID ?? this.sttID,
      userID: userID ?? this.userID,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isShowed: isShowed ?? this.isShowed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'message': message,
      'createdAt': createdAt,
      'isShowed': isShowed,
      'sttID': sttID,
    };
  }

  factory STT.fromMap(Map<String, dynamic> map) {
    return STT(
      userID: map['userID'] ?? "",
      message: map['message'] ?? "",
      sttID: map['sttID'] ?? "",
      createdAt: map['createdAt'] as Timestamp,
      isShowed: map['isShowed'] as bool,
    );
  }

  @override
  String toString() {
    return 'STT(userID: $userID, message: $message, createdAt: $createdAt, isShowed: $isShowed)';
  }

  @override
  bool operator ==(covariant STT other) {
    if (identical(this, other)) return true;

    return other.userID == userID &&
        other.message == message &&
        other.createdAt == createdAt &&
        other.isShowed == isShowed &&
        other.sttID == sttID;
  }

  @override
  int get hashCode {
    return userID.hashCode ^
        message.hashCode ^
        createdAt.hashCode ^
        isShowed.hashCode ^
        sttID.hashCode;
  }
}
