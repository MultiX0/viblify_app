// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Dash {
  final String userID;
  final String dashID;
  final List<dynamic> likes;
  final String title;
  final String contentUrl;
  final String description;
  final int commentCount;
  final String createdAt; // Added field
  final List<dynamic> shares; // Added field
  final List<dynamic> views;
  final List<dynamic> labels;

  Dash({
    required this.userID,
    required this.dashID,
    required this.likes,
    required this.title,
    required this.contentUrl,
    required this.description,
    required this.commentCount,
    required this.labels,
    required this.views,
    required this.createdAt,
    required this.shares,
  });

  Dash copyWith({
    String? userID,
    String? dashID,
    List? likes,
    String? title,
    String? contentUrl,
    String? description,
    int? commentCount,
    List? views,
    String? createdAt,
    List? shares,
    List? tags,
    List? labels,
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
      labels: labels ?? this.labels,
      title: title ?? this.title,
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
      'labels': labels,
      'title': title,
    };
  }

  factory Dash.fromMap(Map<String, dynamic> map) {
    return Dash(
      userID: map['userID'] as String,
      dashID: map['dashID'] as String,
      likes: List<dynamic>.from(map['likes'] as List<dynamic>),
      title: map['title'] ?? "",
      contentUrl: map['contentUrl'] as String,
      description: map['description'] as String,
      commentCount: map['commentCount'] as int,
      views: List<dynamic>.from(map['views'] as List<dynamic>),
      createdAt: map['createdAt'] as String,
      shares: List<dynamic>.from(map['shares'] as List<dynamic>),
      labels: List<dynamic>.from(map['labels'] as List<dynamic>),
    );
  }

  @override
  String toString() {
    return 'Dash(userID: $userID, dashID: $dashID, likes: $likes, contentUrl: $contentUrl, description: $description, commentCount: $commentCount, views: $views, createdAt: $createdAt, shares: $shares)';
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
        listEquals(other.shares, shares);
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
        shares.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory Dash.fromJson(String source) => Dash.fromMap(json.decode(source) as Map<String, dynamic>);
}
