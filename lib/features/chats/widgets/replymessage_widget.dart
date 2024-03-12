import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/models/message_model.dart';

class ReplyMessageWidget extends StatelessWidget {
  final MessageModel message;
  final String userName;
  final VoidCallback? onCancelReply;
  const ReplyMessageWidget(
      {super.key,
      required this.message,
      this.onCancelReply,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 4,
            color: onCancelReply == null ? Colors.blue[700] : Colors.grey[800],
          ),
          const SizedBox(
            width: 8,
          ),
          if (onCancelReply != null)
            Expanded(
              child: buidReplyMessage(context),
            )
          else
            Expanded(
              flex: 1,
              child: buidReplyMessage(context),
            ),
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
                  "replied to : $userName",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onCancelReply != null
                        ? Colors.grey[500]!
                        : Colors.grey[200]!,
                  ),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  onTap: onCancelReply,
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
              style: TextStyle(
                  color: onCancelReply == null
                      ? Colors.grey[400]!
                      : Colors.grey[600],
                  fontSize: 13),
            ),
          ] else ...[
            Container(
              width: MediaQuery.of(context).size.width * 0.13,
              height: MediaQuery.of(context).size.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                image: DecorationImage(
                    image: CachedNetworkImageProvider(message.photoUrl!),
                    fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      );
}
