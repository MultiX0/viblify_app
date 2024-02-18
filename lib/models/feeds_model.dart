import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Feeds {
  final String feedID;
  final String content;
  final String userID;
  final List<dynamic> tags;
  final List<dynamic> likes;
  final List<dynamic> shares;
  final String photoUrl;
  final List<dynamic> views;
  final int commentCount;
  final int likeCount;
  final Timestamp createdAt;
  final bool isCommentsOpen;
  int score;
  final bool isShowed;
  final String gif;
  final String sttID;

  final String youtubeVideoID; // New field: youtubeVideoID

  Feeds({
    required this.feedID,
    required this.content,
    required this.userID,
    required this.sttID,
    required this.tags,
    required this.shares,
    required this.likes,
    required this.photoUrl,
    required this.views,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.isCommentsOpen,
    required this.score,
    required this.isShowed,
    required this.gif,
    required this.youtubeVideoID, // New field: youtubeVideoID
  });

  Feeds copyWith({
    String? feedID,
    String? content,
    String? userID,
    List<dynamic>? tags,
    List<dynamic>? likes,
    List<dynamic>? shares,
    String? photoUrl,
    List<dynamic>? views,
    String? sttID,
    int? commentCount,
    int? likeCount,
    Timestamp? createdAt,
    bool? isCommentsOpen,
    int? score,
    bool? isShowed,
    String? gif,
    String? youtubeVideoID, // New field: youtubeVideoID
  }) {
    return Feeds(
      feedID: feedID ?? this.feedID,
      content: content ?? this.content,
      userID: userID ?? this.userID,
      shares: shares ?? this.shares,
      tags: tags ?? this.tags,
      sttID: sttID ?? this.sttID,
      likes: likes ?? this.likes,
      photoUrl: photoUrl ?? this.photoUrl,
      views: views ?? this.views,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      isCommentsOpen: isCommentsOpen ?? this.isCommentsOpen,
      score: score ?? this.score,
      isShowed: isShowed ?? this.isShowed,
      gif: gif ?? this.gif,
      youtubeVideoID:
          youtubeVideoID ?? this.youtubeVideoID, // New field: youtubeVideoID
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedID': feedID,
      'content': content,
      'userID': userID,
      'tags': tags,
      'likes': likes,
      'shares': shares,
      'photoUrl': photoUrl,
      'views': views,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'createdAt': createdAt,
      'isCommentsOpen': isCommentsOpen,
      'score': score,
      'isShowed': isShowed,
      'sttID': sttID,
      'gif': gif,
      'youtubeVideoID':
          youtubeVideoID, // Include the new field in the map: youtubeVideoID
    };
  }

  factory Feeds.fromMap(Map<String, dynamic> map) {
    return Feeds(
      feedID: map['feedID'] ?? "",
      content: map['content'] ?? "",
      userID: map['userID'] ?? "",
      sttID: map['sttID'] ?? "",
      tags: List<dynamic>.from(map['tags'] as List),
      likes: List<dynamic>.from(map['likes'] as List),
      shares: List<dynamic>.from(map['shares'] as List),
      photoUrl: map['photoUrl'] as String,
      views: List<dynamic>.from(map['views'] as List),
      commentCount: map['commentCount'] as int,
      likeCount: map['likeCount'] as int,
      createdAt: map['createdAt'] as Timestamp,
      isCommentsOpen: map['isCommentsOpen'] as bool,
      score: map['score'] as int,
      isShowed: map['isShowed'] as bool,
      gif: map['gif'] ?? "",
      youtubeVideoID: map['youtubeVideoID'] ??
          "", // Include the new field in the factory constructor
    );
  }

  @override
  String toString() {
    return 'Feeds(feedID: $feedID, content: $content, userID: $userID, tags: $tags, likes: $likes, photoUrl: $photoUrl, views: $views, commentCount: $commentCount, likeCount: $likeCount, createdAt: $createdAt, isCommentsOpen: $isCommentsOpen, score: $score, isShowed: $isShowed, gif: $gif, youtubeVideoID: $youtubeVideoID)';
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
        listEquals(other.shares, shares) &&
        other.commentCount == commentCount &&
        other.likeCount == likeCount &&
        other.createdAt == createdAt &&
        other.isCommentsOpen == isCommentsOpen &&
        other.score == score &&
        other.sttID == sttID &&
        other.isShowed == isShowed &&
        other.gif == gif &&
        other.youtubeVideoID == youtubeVideoID; // Compare the new field
  }

  @override
  int get hashCode {
    return feedID.hashCode ^
        content.hashCode ^
        userID.hashCode ^
        tags.hashCode ^
        likes.hashCode ^
        sttID.hashCode ^
        photoUrl.hashCode ^
        views.hashCode ^
        shares.hashCode ^
        commentCount.hashCode ^
        likeCount.hashCode ^
        createdAt.hashCode ^
        isCommentsOpen.hashCode ^
        score.hashCode ^
        isShowed.hashCode ^
        gif.hashCode ^
        youtubeVideoID.hashCode; // Include the new field in the hash code
  }
}
