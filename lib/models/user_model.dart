// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/encrypt/encrypt.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String bannerPic;
  final String userID;
  final String email;
  final String mbti;
  final String userName;
  final String location;
  final String bio;
  final List following;
  final List followers;
  final List notifications;
  final int points;
  final DateTime joinedAt;
  final bool verified;
  final String link;
  final bool isAccountPrivate;
  final bool isUserOnline;
  final String lastTimeActive;
  final String password;
  final String notificationsToken;

  final bool isUserMod; // New field: isUserMod
  final bool stt; // New field: stt
  final bool isUserBlocked; // New field: isUserBlocked
  final List postLikes;
  final List usersBlock;
  final String profileTheme;
  final bool isThemeDark;
  final String dividerColor;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.bannerPic,
    required this.notifications,
    required this.userID,
    required this.email,
    required this.password,
    required this.notificationsToken,
    required this.lastTimeActive,
    required this.isUserOnline,
    required this.dividerColor,
    required this.profileTheme,
    required this.userName,
    required this.location,
    required this.stt,
    required this.isUserBlocked,
    required this.isThemeDark,
    required this.bio,
    required this.postLikes,
    required this.usersBlock,
    required this.following,
    required this.followers,
    required this.mbti,
    required this.points,
    required this.joinedAt,
    required this.verified,
    required this.link,
    required this.isAccountPrivate,
    required this.isUserMod, // New field: isUserMod
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? bannerPic,
    String? userID,
    String? email,
    String? userName,
    String? location,
    String? lastTimeActive,
    bool? isUserOnline,
    String? notificationsToken,
    String? bio,
    String? dividerColor,
    bool? isThemeDark,
    String? mbti,
    List? following,
    List? notifications,
    bool? isUserBlocked,
    bool? stt,
    List? followers,
    int? points,
    DateTime? joinedAt,
    bool? verified,
    String? profileTheme,
    String? link,
    bool? isAccountPrivate,
    bool? isUserMod, // New field: isUserMod
    List? postLikes,
    List? usersBlock,
    String? password,
  }) {
    return UserModel(
      name: name ?? this.name,
      notificationsToken: notificationsToken ?? this.notificationsToken,
      isUserOnline: isUserOnline ?? this.isUserOnline,
      lastTimeActive: lastTimeActive ?? this.lastTimeActive,
      profilePic: profilePic ?? this.profilePic,
      dividerColor: dividerColor ?? this.dividerColor,
      isThemeDark: isThemeDark ?? this.isThemeDark,
      bannerPic: bannerPic ?? this.bannerPic,
      userID: userID ?? this.userID,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      mbti: mbti ?? this.mbti,
      location: location ?? this.location,
      stt: stt ?? this.stt,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      bio: bio ?? this.bio,
      profileTheme: profileTheme ?? this.profileTheme,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      notifications: notifications ?? this.notifications,
      points: points ?? this.points,
      joinedAt: joinedAt ?? this.joinedAt,
      verified: verified ?? this.verified,
      link: link ?? this.link,
      isAccountPrivate: isAccountPrivate ?? this.isAccountPrivate,
      isUserMod: isUserMod ?? this.isUserMod,
      postLikes: postLikes ?? this.postLikes,
      usersBlock: usersBlock ?? this.usersBlock,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'bannerPic': bannerPic,
      'userID': userID,
      'email': email,
      'userName': userName,
      'location': location,
      'bio': bio,
      'following': following,
      'followers': followers,
      'notifications': notifications,
      'points': points,
      'joinedAt': joinedAt.toIso8601String(),
      'verified': verified,
      'link': link,
      'notificationsToken': notificationsToken,
      'mbti': mbti,
      'lastTimeActive': lastTimeActive,
      'isUserOnline': isUserOnline,
      'isAccountPrivate': isAccountPrivate,
      'isUserMod': isUserMod, // Include the new field in the map
      'isUserBlocked': isUserBlocked,
      'stt': stt,
      'post_likes': postLikes,
      'users_block': usersBlock,
      'profile_theme': profileTheme,
      'user_password': encrypt(password, encryptKey),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'] as String,
        profilePic: map['profilePic'] as String,
        bannerPic: map['bannerPic'] as String,
        notificationsToken: map['notificationsToken'] ?? "",
        mbti: map['mbti'] ?? "",
        isUserOnline: map['isUserOnline'] ?? false,
        lastTimeActive: map['lastTimeActive'] ?? '',
        userID: map['userID'] as String,
        email: map['email'] as String,
        userName: map['userName'] as String,
        location: map['location'] as String,
        bio: map['bio'] as String,
        following: List.from(map['following'] as List),
        followers: List.from(map['followers'] as List),
        notifications: List.from(map['notifications'] as List),
        points: map['points'] as int,
        joinedAt: DateTime.parse(map['joinedAt'] as String),
        verified: map['verified'] == null ? false : map['verified'] as bool,
        link: map['link'] as String,
        isAccountPrivate: map['isAccountPrivate'] == null
            ? false
            : map['isAccountPrivate'] as bool,
        isUserMod: map['isUserMod'] == null ? false : map['isUserMod'] as bool,
        stt: map['stt'] == null ? false : map['stt'] as bool,
        isUserBlocked:
            map['isUserBlocked'] == null ? false : map['isUserBlocked'] as bool,
        postLikes: List.from(map['post_likes'] ?? []),
        usersBlock: List.from(map['users_block'] ?? []),
        profileTheme: map['profile_theme'] ?? "#0d1013",
        isThemeDark: map['is_theme_dark'] ?? true,
        password: decrypt(map['user_password'] ?? "", encryptKey),
        dividerColor: map['divider_color'] ?? "#FFFF");
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, bannerPic: $bannerPic, userID: $userID, email: $email, userName: $userName, location: $location, bio: $bio, following: $following, followers: $followers, points: $points, joinedAt: $joinedAt, verified: $verified, link: $link, isAccountPrivate: $isAccountPrivate, isUserMod: $isUserMod)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePic == profilePic &&
        other.bannerPic == bannerPic &&
        other.userID == userID &&
        other.email == email &&
        other.userName == userName &&
        other.location == location &&
        other.lastTimeActive == lastTimeActive &&
        other.isUserOnline == isUserOnline &&
        other.bio == bio &&
        other.notificationsToken == notificationsToken &&
        listEquals(other.following, following) &&
        listEquals(other.followers, followers) &&
        listEquals(other.notifications, notifications) &&
        other.points == points &&
        other.mbti == mbti &&
        other.joinedAt == joinedAt &&
        other.verified == verified &&
        other.link == link &&
        other.isAccountPrivate == isAccountPrivate &&
        other.isUserMod == isUserMod &&
        other.isUserBlocked == isUserBlocked &&
        other.stt == stt; // Compare the new field
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        bannerPic.hashCode ^
        userID.hashCode ^
        email.hashCode ^
        userName.hashCode ^
        location.hashCode ^
        notificationsToken.hashCode ^
        bio.hashCode ^
        lastTimeActive.hashCode ^
        isUserOnline.hashCode ^
        following.hashCode ^
        followers.hashCode ^
        notifications.hashCode ^
        points.hashCode ^
        joinedAt.hashCode ^
        verified.hashCode ^
        link.hashCode ^
        isAccountPrivate.hashCode ^
        isUserMod.hashCode ^
        mbti.hashCode ^
        stt.hashCode ^
        isUserBlocked.hashCode; // Include the new field in the hash code
  }
}
