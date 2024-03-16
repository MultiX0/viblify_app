import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viblify_app/models/message_model.dart';

class MyImage extends StatelessWidget {
  const MyImage({
    super.key,
    required this.message,
  });

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: message.photoUrl!,
        placeholder: (context, url) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade800,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          );
        },
        imageBuilder: (context, imageProvider) {
          return GestureDetector(
              onTap: () => context.push(
                    "/img/slide/${base64UrlEncode(utf8.encode(message.photoUrl!))}",
                  ),
              child: Image(image: imageProvider));
        },
      ),
    );
  }
}
