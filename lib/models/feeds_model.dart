// Import the necessary core libraries
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Feeds {
  final String feedID;
  final String content;
  final String userID;
  final List<dynamic> tags;
  final List<dynamic> likes;
  final String photoUrl;
  final List<dynamic> views;
  final int commentCount;
  final int likeCount;
  final Timestamp createdAt;
  final bool isCommentsOpen;
  int score;

  Feeds({
    required this.feedID,
    required this.content,
    required this.userID,
    required this.tags,
    required this.likes,
    required this.photoUrl,
    required this.views,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.isCommentsOpen,
    required this.score, // New field: score
  });

  Feeds copyWith({
    String? feedID,
    String? content,
    String? userID,
    List<dynamic>? tags,
    List<dynamic>? likes,
    String? photoUrl,
    List<dynamic>? views,
    int? commentCount,
    int? likeCount,
    Timestamp? createdAt, // Change to Timestamp
    bool? isCommentsOpen,
    int? score, // New field: score
  }) {
    return Feeds(
      feedID: feedID ?? this.feedID,
      content: content ?? this.content,
      userID: userID ?? this.userID,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      photoUrl: photoUrl ?? this.photoUrl,
      views: views ?? this.views,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      isCommentsOpen: isCommentsOpen ?? this.isCommentsOpen,
      score: score ?? this.score, // New field: score
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedID': feedID,
      'content': content,
      'userID': userID,
      'tags': tags,
      'likes': likes,
      'photoUrl': photoUrl,
      'views': views,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'createdAt': createdAt, // Include the new field in the map: createdAt
      'isCommentsOpen': isCommentsOpen,
      'score': score, // Include the new field in the map: score
    };
  }

  factory Feeds.fromMap(Map<String, dynamic> map) {
    return Feeds(
      feedID: map['feedID'] as String,
      content: map['content'] as String,
      userID: map['userID'] as String,
      tags: List<dynamic>.from(map['tags'] as List),
      likes: List<dynamic>.from(map['likes'] as List),
      photoUrl: map['photoUrl'] as String,
      views: List<dynamic>.from(map['views'] as List),
      commentCount: map['commentCount'] as int,
      likeCount: map['likeCount'] as int,
      createdAt: map['createdAt'] as Timestamp, // Change to Timestamp
      isCommentsOpen: map['isCommentsOpen'] as bool,
      score: map['score']
          as int, // Include the new field in the factory constructor
    );
  }

  @override
  String toString() {
    return 'Feeds(feedID: $feedID, content: $content, userID: $userID, tags: $tags, likes: $likes, photoUrl: $photoUrl, views: $views, commentCount: $commentCount, likeCount: $likeCount, createdAt: $createdAt, isCommentsOpen: $isCommentsOpen, score: $score)';
  }

  @override
  bool operator ==(covariant Feeds other) {
    if (identical(this, other)) return true;

    return other.feedID == feedID &&
        other.content == content &&
        other.userID == userID &&
        listEquals(other.tags, tags) &&
        listEquals(other.likes, likes) &&
        other.photoUrl == photoUrl &&
        listEquals(other.views, views) &&
        other.commentCount == commentCount &&
        other.likeCount == likeCount &&
        other.createdAt == createdAt &&
        other.isCommentsOpen == isCommentsOpen &&
        other.score == score; // Compare the new field
  }

  @override
  int get hashCode {
    return feedID.hashCode ^
        content.hashCode ^
        userID.hashCode ^
        tags.hashCode ^
        likes.hashCode ^
        photoUrl.hashCode ^
        views.hashCode ^
        commentCount.hashCode ^
        likeCount.hashCode ^
        createdAt.hashCode ^
        isCommentsOpen.hashCode ^
        score.hashCode; // Include the new field in the hash code
  }
}
