import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/user_profile/controller/user_profile_controller.dart';

class ImageSlidePage extends ConsumerWidget {
  final String imageUrl;

  ImageSlidePage({required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> decodedBytes = base64Url.decode(imageUrl);
    String decoded = utf8.decode(decodedBytes);

    void download() {
      ref
          .watch(userProfileControllerProvider.notifier)
          .downloadImage(decoded, context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
        title: const Text('Image Slide Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OutlinedButton(
              onPressed: download,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.2, 30),
                side: const BorderSide(
                  color: Colors.blue,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Hero(
          tag: decoded,
          child: ExtendedImageSlidePage(
            slideAxis: SlideAxis.both,
            slideType: SlideType.onlyImage,
            child: ExtendedImage.network(
              enableSlideOutPage: true,
              decoded,
              cache: true,
              borderRadius: BorderRadius.circular(0),
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
            ),
          ),
        ),
      ),
    );
  }
}
