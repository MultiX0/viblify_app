// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String bannerPic;
  final String userID;
  final String email;
  final String userName;
  final String location;
  final String bio;
  final List following;
  final List followers;
  final int points;
  final DateTime joinedAt;
  final bool verified;
  final String link;
  final bool isAccountPrivate; // New field

  UserModel({
    required this.name,
    required this.profilePic,
    required this.bannerPic,
    required this.userID,
    required this.email,
    required this.userName,
    required this.location,
    required this.bio,
    required this.following,
    required this.followers,
    required this.points,
    required this.joinedAt,
    required this.verified,
    required this.link,
    required this.isAccountPrivate, // New field
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? bannerPic,
    String? userID,
    String? email,
    String? userName,
    String? location,
    String? bio,
    List? following,
    List? followers,
    int? points,
    DateTime? joinedAt,
    bool? verified,
    String? link,
    bool? isAccountPrivate, // New field
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      bannerPic: bannerPic ?? this.bannerPic,
      userID: userID ?? this.userID,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      points: points ?? this.points,
      joinedAt: joinedAt ?? this.joinedAt,
      verified: verified ?? this.verified,
      link: link ?? this.link,
      isAccountPrivate: isAccountPrivate ?? this.isAccountPrivate, // New field
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
      'points': points,
      'joinedAt': joinedAt.toIso8601String(),
      'verified': verified,
      'link': link,
      'isAccountPrivate': isAccountPrivate, // Include the new field in the map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      bannerPic: map['bannerPic'] as String,
      userID: map['userID'] as String,
      email: map['email'] as String,
      userName: map['userName'] as String,
      location: map['location'] as String,
      bio: map['bio'] as String,
      following: List.from(map['following'] as List),
      followers: List.from(map['followers'] as List),
      points: map['points'] as int,
      joinedAt: DateTime.parse(map['joinedAt'] as String),
      verified: map['verified'] as bool,
      link: map['link'] as String,
      isAccountPrivate: map['isAccountPrivate']
          as bool, // Retrieve the new field from the map
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, bannerPic: $bannerPic, userID: $userID, email: $email, userName: $userName, location: $location, bio: $bio, following: $following, followers: $followers, points: $points, joinedAt: $joinedAt, verified: $verified, link: $link, isAccountPrivate: $isAccountPrivate)';
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
        other.bio == bio &&
        listEquals(other.following, following) &&
        listEquals(other.followers, followers) &&
        other.points == points &&
        other.joinedAt == joinedAt &&
        other.verified == verified &&
        other.link == link &&
        other.isAccountPrivate == isAccountPrivate; // Compare the new field
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
        bio.hashCode ^
        following.hashCode ^
        followers.hashCode ^
        points.hashCode ^
        joinedAt.hashCode ^
        verified.hashCode ^
        link.hashCode ^
        isAccountPrivate.hashCode; // Include the new field in the hash code
  }
}
