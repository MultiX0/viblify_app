import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Comments {
  final String commentID;
  final String content;
  final String userID;
  final List tags;
  final List likes;
  final String photoUrl;
  final Map<String, dynamic> replies;
  final Timestamp createdAt;
  final int score;
  final String gif;
  final bool isShowed; // Renamed variable

  Comments({
    required this.commentID,
    required this.content,
    required this.userID,
    required this.tags,
    required this.likes,
    required this.photoUrl,
    required this.replies,
    required this.createdAt,
    required this.gif,
    required this.score,
    required this.isShowed, // Renamed variable
  });

  Comments copyWith({
    String? commentID,
    String? content,
    String? userID,
    String? gif,
    List? tags,
    List? likes,
    String? photoUrl,
    Map<String, dynamic>? replies,
    Timestamp? createdAt,
    int? score,
    bool? isShowed, // Renamed variable
  }) {
    return Comments(
      commentID: commentID ?? this.commentID,
      content: content ?? this.content,
      userID: userID ?? this.userID,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      photoUrl: photoUrl ?? this.photoUrl,
      replies: replies ?? this.replies,
      gif: gif ?? this.gif,
      createdAt: createdAt ?? this.createdAt,
      score: score ?? this.score,
      isShowed: isShowed ?? this.isShowed, // Renamed variable
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commentID': commentID,
      'content': content,
      'userID': userID,
      'tags': tags,
      'likes': likes,
      'photoUrl': photoUrl,
      'replies': replies,
      'createdAt': createdAt,
      'score': score,
      'gif': gif,
      'isShowed': isShowed, // Renamed variable
    };
  }

  factory Comments.fromMap(Map<String, dynamic> map) {
    return Comments(
      commentID: map['commentID'] as String,
      content: map['content'] as String,
      userID: map['userID'] as String,
      tags: List.from(map['tags']),
      likes: List.from(map['likes']),
      photoUrl: map['photoUrl'] as String,
      replies: map['replies'] as Map<String, dynamic>,
      createdAt: map['createdAt'] as Timestamp,
      score: map['score'] as int,
      gif: map['gif'] as String,
      isShowed: map['isShowed'] as bool, // Renamed variable
    );
  }

  @override
  String toString() {
    return 'Comment(commentID: $commentID, content: $content, userID: $userID, tags: $tags, likes: $likes, photoUrl: $photoUrl, replies: $replies, createdAt: $createdAt, score: $score, isShowed: $isShowed)';
  }

  @override
  bool operator ==(covariant Comments other) {
    if (identical(this, other)) return true;

    return other.commentID == commentID &&
        other.content == content &&
        other.userID == userID &&
        listEquals(other.tags, tags) &&
        listEquals(other.likes, likes) &&
        other.photoUrl == photoUrl &&
        mapEquals(other.replies, replies) &&
        other.createdAt == createdAt &&
        other.score == score &&
        other.isShowed == isShowed; // Renamed variable
  }

  @override
  int get hashCode {
    return commentID.hashCode ^
        content.hashCode ^
        userID.hashCode ^
        tags.hashCode ^
        likes.hashCode ^
        photoUrl.hashCode ^
        replies.hashCode ^
        createdAt.hashCode ^
        score.hashCode ^
        isShowed.hashCode; // Renamed variable
  }
}
