import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/models/message_model.dart';

class ChatReplyMessageWidget extends StatelessWidget {
  final MessageModel message;

  const ChatReplyMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 4,
            color: Colors.transparent,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: buidReplyMessage(context),
          )
        ],
      ),
    );
  }

  Widget buidReplyMessage(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "replied to : ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          if (message.photoUrl == null) ...[
            Text(
              decrypt(message.text!, encryptKey),
              style: const TextStyle(color: Colors.transparent, fontSize: 13),
            ),
          ] else ...[
            Container(
              width: MediaQuery.of(context).size.width * 0.13,
              height: MediaQuery.of(context).size.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: Colors.transparent,
                image: DecorationImage(
                    image: CachedNetworkImageProvider(message.photoUrl!),
                    fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      );
}
