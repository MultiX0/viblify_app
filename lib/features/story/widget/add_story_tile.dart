// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:viblify_app/core/utils.dart';

import 'package:vs_story_designer/vs_story_designer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/pallete.dart';
import '../controller/story_controller.dart';

final GlobalKey _globalKey = GlobalKey();

class AddStoryTile extends ConsumerWidget {
  final String imgUrl;
  const AddStoryTile({super.key, required this.imgUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          // onTap: () => context.push("/create_story"),
          onTap: () async {
            String? mediaPath = await _prepareImage();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VSStoryDesigner(
                  key: _globalKey,
                  middleBottomWidget: const SizedBox(),
                  centerText: "create an awesome story",
                  galleryThumbnailQuality: 250,
                  onDone: (uri) {
                    // Share.shareFiles([uri]);
                    ref
                        .watch(storyControllerProvider.notifier)
                        .postStory(image: File(uri), context: context);
                  },
                  onDoneButtonStyle: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Post",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 14,
                        )
                      ],
                    ),
                  ),
                  mediaPath: mediaPath,
                ),
              ),
            );
          },
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
                Positioned(
                  top: 72,
                  left: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    radius: 16,
                    child: const Icon(Icons.add),
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

Future<String?> _prepareImage() async {
  String? path;

  try {
    var result = await pickImage();
    if (result != null) {
      path = result.files.first.path;
    }
    return path;
  } catch (e) {
    return null;
  }
}
