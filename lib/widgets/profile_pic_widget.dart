// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';

class ProfileImageScreen extends ConsumerWidget {
  final String url;
  final String tag;
  const ProfileImageScreen({super.key, required this.tag, required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> decodedBytes = base64Url.decode(url);
    String decodedUrl = utf8.decode(decodedBytes);

    void download() {
      print("object");
      context.pop();
      ref
          .watch(userProfileControllerProvider.notifier)
          .downloadImage(decodedUrl, context);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("1 of 1"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              print("========================");
              print(decodedUrl);
              showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: false,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text("Download"),
                          leading: const Icon(LineIcons.download),
                          onTap: download,
                        )
                      ],
                    );
                  });
            },
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: Hero(
        tag: tag,
        child: Center(
          child: ExtendedImageSlidePage(
            slideAxis: SlideAxis.both,
            slideType: SlideType.onlyImage,
            child: ExtendedImage.network(
              width: double.infinity,
              borderRadius: BorderRadius.circular(0),
              enableSlideOutPage: true,
              decodedUrl,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
            ),
          ),
        ),
      ),
    );
  }
}
