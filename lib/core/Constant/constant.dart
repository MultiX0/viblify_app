import 'package:flutter/material.dart';
import 'package:viblify_app/features/Feed/feed_screen.dart';
import 'package:viblify_app/features/user_profile/screens/add_post.dart';
import 'package:viblify_app/features/user_profile/screens/search_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';

class Constant {
  static const logoPath = 'assets/images/logo.png';
  static const cryPath = 'assets/images/cry.gif';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';

  static const bannerDefault =
      'https://firebasestorage.googleapis.com/v0/b/viblify.appspot.com/o/bannerPic.jpg?alt=media&token=1a046e78-2b1d-4bd0-a83e-b77985a3219f';
  static const avatarDefault =
      'https://firebasestorage.googleapis.com/v0/b/viblify.appspot.com/o/groupPic.jpg?alt=media&token=0b80e30b-c536-4f5d-8a88-564d9b66302d';

  static List navBar({
    required String uid,
  }) {
    List<Widget> tabWidget = [
      const FeedScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const Center(),
      UserProfileScreen(uid: uid),
    ];
    return tabWidget;
  }
}
