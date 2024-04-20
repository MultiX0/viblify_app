import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryInfoTile extends StatelessWidget {
  final String avatar;
  final String user_name;
  final String publish_date;
  const StoryInfoTile(
      {super.key, required this.avatar, required this.publish_date, required this.user_name});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(publish_date);
    final createdAt = timeago.format(dateTime, locale: 'en');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatar),
            backgroundColor: Colors.grey[900],
            radius: 16,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            user_name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            createdAt,
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
