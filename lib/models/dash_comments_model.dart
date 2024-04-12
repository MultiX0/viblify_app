class DashCommentsModel {
  final String userID;
  final String dashID;
  final String commentID;
  final List<dynamic> likes;
  final String? createdAt;
  final String content;
  DashCommentsModel({
    required this.userID,
    required this.dashID,
    required this.likes,
    required this.commentID,
    required this.content,
    this.createdAt,
  });

  DashCommentsModel copyWith({
    String? userID,
    String? dashID,
    String? commentID,
    String? content,
    String? createdAt,
    List? likes,
  }) {
    return DashCommentsModel(
      userID: userID ?? this.userID,
      dashID: dashID ?? this.dashID,
      likes: likes ?? this.likes,
      commentID: commentID ?? this.commentID,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'dashID': dashID,
      'likes': likes,
      'content': content,
      'commentID': commentID,
    };
  }

  factory DashCommentsModel.fromMap(Map<String, dynamic> map) {
    return DashCommentsModel(
        userID: map['userID'] as String,
        dashID: map['dashID'] as String,
        likes: List<dynamic>.from(map['likes'] as List<dynamic>),
        content: map['content'] as String,
        commentID: map['commentID'] as String,
        createdAt: map['createdAt']);
  }
}
