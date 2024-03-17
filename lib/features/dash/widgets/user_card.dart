import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/models/user_model.dart';

import '../../../core/common/follow_button.dart';

class UserCard extends ConsumerWidget {
  final String uid;
  const UserCard({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel myData = ref.watch(userProvider)!;

    final isUserFollowed = ref.watch(isUserFollowingProvider(uid));
    final bool isFollowingUser = isUserFollowed.maybeWhen(
      data: (boolValue) => boolValue, // Use a default value if null
      orElse: () => false, // Handle other cases (loading, error)
    );
    return ref.watch(getUserDataProvider(uid)).when(
        data: (user) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => navigateToUserScreen(context, uid),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[900],
                    backgroundImage: CachedNetworkImageProvider(user.profilePic),
                  ),
                ),
                GestureDetector(onTap: () => navigateToUserScreen(context, uid), child: userName(user)),
                const Spacer(),
                Text(
                  "${user.followers.length} follower",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[400]),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (uid != myData.userID) ...[
                  FollowButton(
                    isFollowingUser: isFollowingUser,
                    myData: myData,
                    user: user,
                  ),
                ],
              ],
            ),
          );
        },
        error: (error, trace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }

  void navigateToUserScreen(BuildContext context, String uid) {
    context.push("/u/$uid");
  }

  Padding userName(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            "@${user.userName}",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
