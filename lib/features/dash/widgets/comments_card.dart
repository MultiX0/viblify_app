import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viblify_app/models/dash_model.dart';
import 'package:viblify_app/models/user_model.dart';

class MyCommentCard extends StatelessWidget {
  const MyCommentCard({
    super.key,
    required this.dash,
    required this.myData,
  });

  final Dash dash;
  final UserModel myData;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Text(
                "Comments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                dash.commentCount.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]!),
              )
            ],
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
                Text(
                  "add new comment",
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
