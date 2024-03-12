import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/features/chats/widgets/replychat_widget.dart';
import 'package:viblify_app/models/message_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MySwipeWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback callback;

  const MySwipeWidget({Key? key, required this.child, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (data) => callback(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete', // Use caption instead of label
          ),
        ],
      ),
      child: child,
    );
  }
}

class MyReply extends StatelessWidget {
  final bool isMe;
  final Widget child;
  final VoidCallback callback;

  const MyReply(
      {Key? key,
      required this.child,
      required this.callback,
      required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey(0),
      direction:
          isMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
      confirmDismiss: (a) async {
        print("Swiped to the end!");
        callback();
        return null;
      },
      background: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(left: isMe ? 0 : 20, right: isMe ? 20 : 0),
          child: const Icon(
            Icons.replay_rounded,
            color: Colors.white,
          ),
        ),
      ),
      child: child,
    );
  }
}

class ChatSwipe extends StatelessWidget {
  final Widget child;
  final List<MessageModel> messages;

  const ChatSwipe({Key? key, required this.child, required this.messages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey(0),
      direction: DismissDirection.endToStart,
      confirmDismiss: (a) async {
        print("Swiped to the end!");
        return null;
      },
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.transparent,
        child: SizedBox(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: Column(children: [
                    Row(children: [
                      const SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        timeago
                            .format(message.createdAt!.toDate(),
                                locale: 'en_short')
                            .toString(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                      ),
                      if (message.photoUrl == null) ...[
                        if (message.replieMessage != null) ...[
                          ZoomTapAnimation(
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width / 1.75),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: message.link!.isNotEmpty &&
                                      message.link != null
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        buildReply(message),
                                        Text(
                                          decrypt(message.text!, encryptKey),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        buildReply(message),
                                        Text(
                                          decrypt(message.text!, encryptKey),
                                          style: const TextStyle(
                                              color: Colors.transparent),
                                        ),
                                      ],
                                    ),
                            ),
                          )
                        ] else ...[
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 1.5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                message.link!.isNotEmpty && message.link != null
                                    ? Text(
                                        decrypt(message.text!, encryptKey),
                                        style: const TextStyle(
                                            color: Colors.transparent),
                                      )
                                    : Text(
                                        decrypt(message.text!, encryptKey),
                                        style: const TextStyle(
                                            color: Colors.transparent),
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
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ExtendedImage.network(
                                message.photoUrl!,
                                color: Colors.transparent,
                                cache: true,
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        )
                      ],
                    ])
                  ]),
                );
              },
            ),
          ),
        ),
      ),
      child: child,
    );
  }

  Widget buildReply(MessageModel message) => Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ChatReplyMessageWidget(
          message: message.replieMessage!,
        ),
      );
}
