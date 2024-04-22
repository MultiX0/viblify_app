import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/pallete.dart';
import '../enums/request_type.dart';
import '../models/image_generate_ai_model.dart';
import 'parse_text.dart';
import 'text_typing_animation.dart';

class BotHeader extends StatelessWidget {
  const BotHeader({
    Key? key,
    required this.prompt,
    required this.size,
    required this.response_date,
    required this.request_type,
    required this.isLoading,
  }) : super(key: key);

  final ImageGenerateAiModel prompt;
  final bool isLoading;
  final Size size;
  final AiRequestType request_type;
  final String response_date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[900],
                backgroundImage: const AssetImage("assets/images/ai.jpg"),
                radius: 16,
              ),
              const SizedBox(
                width: 8,
              ),
              const Text(
                "viblify.ai",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (prompt.request_type == AiRequestType.image_ai) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: prompt.img_url.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Hero(
                        tag: prompt.img_url,
                        child: GestureDetector(
                          onTap: () => context.push(
                            "/img/slide/${base64UrlEncode(utf8.encode(prompt.img_url))}",
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                              width: size.width * 0.5,
                              height: size.width * 0.5,
                              image: CachedNetworkImageProvider(
                                prompt.img_url,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        response_date,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: DenscordColors.scaffoldForeground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: (prompt.hasError)
                        ? const Text(
                            "I'm very sorry. It seems like an error occurred. Please try again")
                        : const TypingAnimation(),
                  ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: prompt.response.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: size.width * 0.75),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: DenscordColors.scaffoldForeground,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          child: parseText(prompt.response),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        response_date,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: DenscordColors.scaffoldForeground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: (prompt.hasError)
                        ? const Text(
                            "I'm very sorry. It seems like an error occurred. Please try again")
                        : const TypingAnimation(),
                  ),
          ),
        ],
      ],
    );
  }
}
