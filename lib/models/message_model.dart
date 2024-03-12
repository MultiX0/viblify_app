import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? link;
  String? text;
  String? photoUrl;
  String? gif;
  bool? seen;
  Timestamp? createdAt;
  MessageModel? replieMessage; // New field

  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.link,
    this.gif,
    this.createdAt,
    this.photoUrl,
    this.replieMessage, // Initialize the new field
  });

  MessageModel copyWith({
    String? messageid,
    String? sender,
    String? text,
    String? link,
    String? photoUrl,
    String? gif,
    bool? seen,
    Timestamp? createdAt,
    MessageModel? replieMessage, // Include in copyWith
  }) {
    return MessageModel(
      messageid: messageid ?? this.messageid,
      seen: seen ?? this.seen,
      text: text ?? this.text,
      link: link ?? this.link,
      photoUrl: photoUrl ?? this.photoUrl,
      sender: sender ?? this.sender,
      gif: gif ?? this.gif,
      createdAt: createdAt ?? this.createdAt,
      replieMessage: replieMessage ?? this.replieMessage, // Update in copyWith
    );
  }

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    gif = map["gif"];
    text = map["text"];
    link = map['link'] ?? "";
    photoUrl = map["photoUrl"];
    seen = map["seen"];
    createdAt = map["createdAt"];
    replieMessage = map['replieMessage'] != null
        ? MessageModel.fromMap(map['replieMessage'])
        : null; // Deserialize replieMessage
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "link": link,
      "createdAt": createdAt,
      "gif": gif,
      "photoUrl": photoUrl,
      "replieMessage": replieMessage?.toMap(), // Serialize replieMessage
    };
  }
}
