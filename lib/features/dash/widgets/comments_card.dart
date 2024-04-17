import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';
import 'package:viblify_app/features/dash/comments/models/dash_model.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';

class MyCommentCard extends ConsumerWidget {
  const MyCommentCard({
    super.key,
    required this.dash,
    required this.myData,
  });

  final Dash dash;
  final UserModel myData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void likeHunlidng(String dashID) {
      ref.watch(dashControllerProvider.notifier).likeHundling(dashID, myData.userID);
    }

    Future<bool> onLikeButtonTapped(bool isLiked, String docID) async {
      likeHunlidng(docID);
      return !isLiked;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[900],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          ref.watch(getDashByIDProvider(dash.dashID)).when(
                data: (data) {
                  bool postLiked = data.likes.contains(myData.userID);
                  return Row(
                    children: [
                      const Text(
                        "Comments",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data.commentCount.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]!),
                      ),
                      const Spacer(),
                      LikeButton(
                        size: 19,
                        onTap: (isLiked) => onLikeButtonTapped(isLiked, dash.dashID),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            postLiked ? Icons.favorite : Icons.favorite_border,
                            color: postLiked ? Colors.pinkAccent : Colors.grey[600],
                            size: 19,
                          );
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data.likes.length.toString(),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
                error: (error, trace) => ErrorText(error: error.toString()),
                loading: () => const Text("Loading..."),
              ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: CachedNetworkImageProvider(myData.profilePic),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () => navigationToDashCommentScreen(context, dash.dashID, dash.userID),
                  child: Text(
                    "add new comment",
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void navigationToDashCommentScreen(BuildContext context, String dashID, String dashUserID) {
    context.push("/dash_comments/$dashID/$dashUserID");
  }
}
