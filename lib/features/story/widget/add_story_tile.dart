import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/pallete.dart';

class AddStoryTile extends StatelessWidget {
  final String imgUrl;
  const AddStoryTile({super.key, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        top: 10,
        bottom: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => context.push("/create_story"),
          child: Container(
            color: DenscordColors.scaffoldForeground,
            height: 150,
            width: 90,
            child: Stack(
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Image(
                    image: CachedNetworkImageProvider(imgUrl),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const Positioned(
                  top: 72,
                  left: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.add),
                  ),
                ),
                const Positioned(
                  left: 10,
                  right: 10,
                  bottom: 5,
                  child: Column(
                    children: [
                      Text('Create'),
                      Text('Story'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
