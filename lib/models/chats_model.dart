import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String? lastMessage;
  final String? id;
  final List? typing;
  final List? inTheChat;
  final List? members; // Changed to List<dynamic>
  final Timestamp? createdAt;
  final Timestamp? lastMessageDate;
  final String? type; // New property

  ChatModel({
    this.lastMessage,
    this.id,
    this.inTheChat,
    this.lastMessageDate,
    this.typing,
    this.members,
    this.createdAt,
    this.type, // Added the new property
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      lastMessage: map['lastMessage'],
      inTheChat: map['inTheChat'] ?? [],
      id: map['id'],
      typing: map['typing'] ?? [],
      members: map['members'] ?? [],
      createdAt: map['createdAt'],
      lastMessageDate: map['lastMessageDate'],
      type: map['type'] ?? "chat",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastMessage': lastMessage,
      'lastMessageDate': lastMessageDate,
      'id': id,
      'typing': typing,
      'members': members,
      'inTheChat': inTheChat,
      'createdAt': createdAt,
      'type': type, // Include the new property
    };
  }
}
