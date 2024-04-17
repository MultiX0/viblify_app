import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';
import 'package:viblify_app/utils/my_date.dart';

class ChatHeader extends StatelessWidget {
  final UserModel user;
  const ChatHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/u/${user.userID}"),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: CachedNetworkImageProvider(user.profilePic),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style:
                        const TextStyle(fontSize: 15, fontFamily: "", fontWeight: FontWeight.bold),
                  ),
                  if (user.verified) ...[
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 14,
                    ),
                  ],
                ],
              ),
              Text(
                user.isUserOnline
                    ? "Online"
                    : MyDateUtil.getLastActiveTime(
                        context: context, lastActive: user.lastTimeActive),
                style: TextStyle(fontSize: 12, fontFamily: "", color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
