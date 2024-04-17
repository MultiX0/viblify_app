// ignore_for_file: camel_case_types

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'dart:ui' as ui;
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/features/chats/widgets/my_image.dart';
import 'package:viblify_app/features/chats/widgets/replymessage_widget.dart';
import 'package:viblify_app/models/message_model.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../../core/Constant/constant.dart';

class myTile extends StatelessWidget {
  const myTile({
    Key? key,
    required this.isMe,
    required this.messages,
    required this.user,
    required this.myData,
    required this.index,
    required this.chatID,
    required this.message,
  }) : super(key: key);

  final bool isMe;
  final UserModel user;
  final String chatID;

  final UserModel myData;
  final MessageModel message;
  final int index;
  final List messages;

  @override
  Widget build(BuildContext context) {
    bool isLastMessage = message == messages.first;
    bool isPreviousMe = index > 0 && messages[index - 1].sender == user.userID;
    String msg = message.text != null ? decrypt(message.text!, encryptKey) : "";

    bool isNextDifferentUser =
        index > messages.length - 1 && messages[index + 1].sender != message.sender;
    return Directionality(
      textDirection: isMe ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 0 : 15,
          right: isMe ? 15 : 0,
          top: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isPreviousMe && !isMe) ...[
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  if (!isMe && !isNextDifferentUser) ...[
                    GestureDetector(
                      onTap: () => context.push("/u/${user.userID}"),
                      child: Container(
                        width: 34,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image(
                            image: CachedNetworkImageProvider(user.profilePic),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
                if (message.photoUrl == null) ...[
                  if (message.replieMessage != null) ...[
                    ZoomTapAnimation(
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !isMe ? Colors.grey[900]!.withOpacity(0.7) : Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isMe ? Colors.grey[850]! : Colors.grey[900]!),
                        ),
                        child: message.link!.isNotEmpty && message.link != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildReply(),
                                  Align(
                                    alignment: Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Linkable(
                                      text: msg,
                                      textColor: Colors.white,
                                      textDirection:
                                          Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                              ? ui.TextDirection.rtl
                                              : ui.TextDirection.ltr,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildReply(),
                                  Align(
                                    alignment: Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      msg,
                                      textDirection:
                                          Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                              ? ui.TextDirection.rtl
                                              : ui.TextDirection.ltr,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )
                  ] else ...[
                    ZoomTapAnimation(
                      onLongTap: () => FlutterClipboard.copy(msg).then((value) {
                        Fluttertoast.showToast(msg: "تم نسخ الرساله");
                      }),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !isMe ? Colors.grey[900]!.withOpacity(0.7) : Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isMe ? Colors.grey[850]! : Colors.grey[900]!),
                        ),
                        child: message.link!.isNotEmpty && message.link != null
                            ? Linkable(
                                text: msg,
                                textColor: Colors.white,
                                textDirection: Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                    ? ui.TextDirection.rtl
                                    : ui.TextDirection.ltr,
                              )
                            : Text(
                                msg,
                                textDirection: Bidi.hasAnyRtl(decrypt(message.text!, encryptKey))
                                    ? ui.TextDirection.rtl
                                    : ui.TextDirection.ltr,
                              ),
                      ),
                    ),
                  ],
                ] else ...[
                  Hero(
                    tag: message.photoUrl!,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.7,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: !isMe ? Colors.grey[900]!.withOpacity(0.7) : Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isMe ? Colors.grey[850]! : Colors.grey[900]!),
                      ),
                      child: MyImage(message: message),
                    ),
                  ),
                ],
                const SizedBox(
                  width: 8,
                ),
                Text(
                  timeago.format(message.createdAt!.toDate(), locale: 'en_short').toString(),
                  style: TextStyle(color: Colors.grey[800], fontSize: 11),
                ),
              ],
            ),
            if (isLastMessage && (message.sender == myData.userID) && (message.seen == true)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "seen",
                  style: TextStyle(color: Colors.grey[600]!),
                ),
              )
            ] else ...[
              const SizedBox()
            ],
          ],
        ),
      ),
    );
  }

  Widget buildReply() => Directionality(
        textDirection: isMe ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: ReplyMessageWidget(
            message: message.replieMessage!,
            userName: message.replieMessage!.sender != user.userID ? "yourself" : user.userName,
          ),
        ),
      );
}
