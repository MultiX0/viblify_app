import 'package:flutter/foundation.dart' show immutable;

@immutable
class Story {
  final String content_url;
  final DateTime createdAt;
  final String storyID;
  final String userID;
  final List<dynamic> views;
  const Story({
    required this.content_url,
    required this.createdAt,
    required this.storyID,
    required this.userID,
    required this.views,
  });

  Story copyWith({
    String? content_url,
    DateTime? createdAt,
    String? storyID,
    String? userID,
    List<String>? views,
  }) {
    return Story(
      content_url: content_url ?? this.content_url,
      createdAt: createdAt ?? this.createdAt,
      storyID: storyID ?? this.storyID,
      userID: userID ?? this.userID,
      views: views ?? this.views,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'content_url': content_url,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'storyID': storyID,
      'userID': userID,
      'views': views,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      content_url: map['content_url'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      storyID: map['storyID'] as String,
      userID: map['userID'] as String,
      views: List<String>.from(
        (map['views'] as List<dynamic>),
      ),
    );
  }
}
