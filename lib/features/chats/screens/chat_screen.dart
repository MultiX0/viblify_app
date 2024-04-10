// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/chats/controller/chats_controller.dart';
import 'package:viblify_app/features/chats/widgets/chat_header.dart';
import 'package:viblify_app/features/chats/widgets/empty_chat.dart';
import 'package:viblify_app/features/chats/widgets/my_tile.dart';
import 'package:viblify_app/features/chats/widgets/replymessage_widget.dart';
import 'package:viblify_app/features/chats/widgets/swipeable.dart';
import 'package:viblify_app/models/message_model.dart';
import 'package:viblify_app/models/user_model.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'dart:ui' as ui;

import '../repository/update_messages_status.dart';

TextEditingController messageController = TextEditingController();
ScrollController scollController = ScrollController();

class ChatScreen extends ConsumerStatefulWidget {
  final String targetUserID;
  final String chatID;
  const ChatScreen({
    super.key,
    required this.targetUserID,
    required this.chatID,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  MessageModel? repliedMessage;
  bool isCalling = false;
  final focusNode = FocusNode();
  File? img;
  bool arabic = true;
  late AnimationController _fadeController;

  Map<String, AnimationController> fadeAnimationControllers = {};

  @override
  void initState() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final myID = FirebaseAuth.instance.currentUser?.uid ?? "";
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      log("pasue");
      UpdateMessagesStatus().updateChatRoomStatus(myID, widget.targetUserID, widget.chatID, false);
    } else if (state == AppLifecycleState.detached) {
      UpdateMessagesStatus().updateChatRoomStatus(myID, widget.targetUserID, widget.chatID, false);
    } else {
      UpdateMessagesStatus().updateChatRoomStatus(myID, widget.targetUserID, widget.chatID, false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    for (var controller in fadeAnimationControllers.values) {
      controller.dispose();
    }

    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myData = ref.watch(userProvider)!;
    double offset = 0.0;
    final isReplying = repliedMessage != null;

    return WillPopScope(
      onWillPop: () async {
        messageController.clear();
        UpdateMessagesStatus()
            .updateChatRoomStatus(myData.userID, widget.targetUserID, widget.chatID, false);

        // UpdateMessagesStatus().inTheChatStatus(widget.chatID, myData.userID);
        return true;
      },
      child: ref.watch(getUserDataProvider(widget.targetUserID)).when(
            data: (user) {
              return ref.watch(getChatRoomByID(widget.targetUserID)).when(
                  data: (chat) {
                    bool inTheChat = chat.inTheChat!.contains(widget.targetUserID);
                    void send() {
                      String msg = messageController.text.trim();
                      if (msg.isNotEmpty || img != null) {
                        messageController.clear();
                        ref.read(chatsControllerProvider.notifier).sendMessage(
                            chatID: widget.chatID,
                            replieMessage: repliedMessage,
                            sender: myData.userID,
                            reciver: user.userID,
                            inTheChat: inTheChat,
                            targetUser: user,
                            image: img,
                            myData: myData,
                            gif: null,
                            content: msg,
                            context: context);
                        UpdateMessagesStatus().updateChatRoomStatus(
                            myData.userID, widget.targetUserID, widget.chatID, false);
                        scollController.jumpTo(0);
                      }
                      if (repliedMessage != null) {
                        setState(() {
                          repliedMessage = null;
                        });
                      }
                      if (img != null) {
                        setState(() {
                          img = null;
                        });
                      }
                    }

                    void selectImage() async {
                      final result = await pickImage();

                      if (result != null) {
                        setState(() {
                          img = File(result.files.first.path!);
                        });
                        send();
                      }
                    }

                    return myChat(context, user, myData, offset, isReplying, selectImage, send);
                  },
                  error: (error, trace) => ErrorText(error: error.toString()),
                  loading: () => const SizedBox());
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }

  Scaffold myChat(BuildContext context, UserModel user, UserModel myData, double offset,
      bool isReplying, Function() selectImage, Function() send) {
    return Scaffold(
      appBar: AppBar(
        title: ChatHeader(
          user: user,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          ref.watch(getAllMessagesProvider(widget.targetUserID)).when(
                data: (messages) {
                  if (messages.isNotEmpty) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 30,
                        ),
                        child: ListView.builder(
                          controller: scollController,
                          reverse: true,
                          primary: false,
                          shrinkWrap: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            bool isMe = message.sender == myData.userID;

                            if (!message.seen! && message.sender != myData.userID) {
                              ref.read(chatsControllerProvider.notifier).setChatMessageSeen(context,
                                  user.userID, myData.userID, message.messageid!, widget.chatID);
                            }

                            // Fade Animation
                            if (!fadeAnimationControllers.containsKey(message.messageid)) {
                              fadeAnimationControllers[message.messageid!] = AnimationController(
                                duration: const Duration(milliseconds: 600),
                                vsync: this,
                              );
                              fadeAnimationControllers[message.messageid]!.forward(from: 0.0);
                            }

                            return MyReply(
                              callback: () {
                                replyToMessage(message);
                                focusNode.requestFocus();
                              },
                              isMe: isMe,
                              child: myTile(
                                index: index,
                                chatID: widget.chatID,
                                isMe: isMe,
                                myData: myData,
                                message: message,
                                user: user,
                                messages: messages,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const EmptyChat();
                  }
                },
                error: (error, trace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
          ref.watch(getMembersStatus(user.userID)).when(
              data: (typing) {
                if (typing.typing) {
                  _fadeController.forward();
                } else {
                  _fadeController.reverse();
                }

                return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: typing.typing
                        ? Padding(
                            key: ValueKey<bool>(typing.typing),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  curve: Curves.easeInOut,
                                  parent: _fadeController,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundImage: CachedNetworkImageProvider(user.profilePic),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "is typing...",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox());
              },
              error: (error, trace) => ErrorText(error: error.toString()),
              loading: () => const SizedBox()),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
            child: Column(
              children: [
                if (isReplying)
                  buildReply(
                    user,
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                          color: Colors.grey[900],
                        ),
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: TextFormField(
                            focusNode: focusNode,
                            scrollPhysics: const NeverScrollableScrollPhysics(),
                            cursorColor: const Color(0xFF0D47A1),
                            cursorHeight: 25,
                            onChanged: (val) {
                              setState(() {
                                arabic = Bidi.hasAnyRtl(val);
                              });
                              UpdateMessagesStatus().updateChatRoomStatus(
                                  myData.userID,
                                  widget.targetUserID,
                                  widget.chatID,
                                  val.isNotEmpty ? true : false);
                            },
                            controller: messageController,
                            textDirection: arabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                            style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 13),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            enableInteractiveSelection: true,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              alignLabelWithHint: true,
                              hintTextDirection: ui.TextDirection.rtl,
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 13),
                              hintText: "كتابة رسالة",
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (messageController.text.isEmpty) ...[
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                        ),
                        child: IconButton(
                          splashRadius: 8,
                          padding: EdgeInsets.zero,
                          onPressed: selectImage,
                          icon: Icon(
                            Icons.photo_library,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                          color: Colors.grey[900],
                        ),
                        child: IconButton(
                          splashRadius: 8,
                          padding: EdgeInsets.zero,
                          onPressed: null,
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                    if (messageController.text.isNotEmpty) ...[
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                          color: Colors.grey[900],
                        ),
                        child: TextButton(
                          onPressed: send,
                          child: Text(
                            "Send",
                            style: TextStyle(
                                color: Pallete.blueColor.withOpacity(0.7),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void replyToMessage(MessageModel message) {
    setState(() {
      repliedMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      repliedMessage = null;
    });
  }

  Widget buildReply(UserModel user) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Pallete.blackColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ReplyMessageWidget(
          message: repliedMessage!,
          onCancelReply: cancelReply,
          userName: repliedMessage!.sender != user.userID ? "yourself" : user.userName,
        ),
      );
}
