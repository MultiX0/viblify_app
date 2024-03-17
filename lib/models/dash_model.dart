import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Dash {
  final String userID;
  final String dashID;
  final List<dynamic> likes;
  final String contentUrl;
  final String description;
  final int commentCount;
  final int views;
  final String createdAt; // Added field
  final List<dynamic> shares; // Added field
  final List<dynamic> tags; // Added field

  Dash({
    required this.userID,
    required this.dashID,
    required this.likes,
    required this.contentUrl,
    required this.description,
    required this.commentCount,
    required this.views,
    required this.createdAt,
    required this.shares,
    required this.tags,
  });

  Dash copyWith({
    String? userID,
    String? dashID,
    List? likes,
    String? contentUrl,
    String? description,
    int? commentCount,
    int? views,
    String? createdAt,
    List? shares,
    List? tags,
  }) {
    return Dash(
      userID: userID ?? this.userID,
      dashID: dashID ?? this.dashID,
      likes: likes ?? this.likes,
      contentUrl: contentUrl ?? this.contentUrl,
      description: description ?? this.description,
      commentCount: commentCount ?? this.commentCount,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      shares: shares ?? this.shares,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'dashID': dashID,
      'likes': likes,
      'contentUrl': contentUrl,
      'description': description,
      'commentCount': commentCount,
      'views': views,
      'createdAt': createdAt,
      'shares': shares,
      'tags': tags,
    };
  }

  factory Dash.fromMap(Map<String, dynamic> map) {
    return Dash(
      userID: map['userID'] ?? "",
      dashID: map['dashID'] ?? "",
      likes: List.from(map['likes'] ?? []),
      contentUrl: map['contentUrl'] ?? "",
      description: map['description'] ?? "",
      commentCount: map['commentCount'] ?? 0,
      views: map['views'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now().millisecondsSinceEpoch.toString(),
      shares: List.from(map['shares'] ?? []),
      tags: List.from(map['tags'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Dash(userID: $userID, dashID: $dashID, likes: $likes, contentUrl: $contentUrl, description: $description, commentCount: $commentCount, views: $views, createdAt: $createdAt, shares: $shares, tags: $tags)';
  }

  @override
  bool operator ==(covariant Dash other) {
    if (identical(this, other)) return true;

    return other.userID == userID &&
        other.dashID == dashID &&
        listEquals(other.likes, likes) &&
        other.contentUrl == contentUrl &&
        other.description == description &&
        other.commentCount == commentCount &&
        other.views == views &&
        other.createdAt == createdAt &&
        listEquals(other.shares, shares) &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return userID.hashCode ^
        dashID.hashCode ^
        likes.hashCode ^
        contentUrl.hashCode ^
        description.hashCode ^
        commentCount.hashCode ^
        views.hashCode ^
        createdAt.hashCode ^
        shares.hashCode ^
        tags.hashCode;
  }
}
