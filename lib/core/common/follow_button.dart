import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/models/user_model.dart';

class FollowButton extends ConsumerWidget {
  const FollowButton({
    super.key,
    required this.isFollowingUser,
    required this.myData,
    required this.user,
  });

  final bool isFollowingUser;
  final UserModel user;
  final UserModel myData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void toggleFollow() {
      ref.watch(userProfileControllerProvider.notifier).toggleFollow(myData.userID, user.userID);
    }

    return OutlinedButton(
      onPressed: toggleFollow,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.2, 30),

        side: BorderSide(
          color: isFollowingUser
              ? user.isThemeDark
                  ? Colors.white
                  : Colors.black
              : user.isThemeDark
                  ? Colors.blue
                  : Colors.black, // Set the border color
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Adjust the border radius as needed
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), // Adjust the padding as needed
      ),
      child: Text(
        isFollowingUser
            ? "unfollow"
            : myData.followers.contains(user.userID)
                ? "follow back"
                : "follow",
        style: TextStyle(
            fontSize: 12,
            color: isFollowingUser
                ? user.isThemeDark
                    ? Colors.white
                    : Colors.black
                : user.isThemeDark
                    ? Colors.blue
                    : Colors.black),
      ),
    );
  }
}
