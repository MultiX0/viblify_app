import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/chats/controller/chats_controller.dart';
import 'package:viblify_app/features/chats/widgets/swipeable.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

import '../../../core/Constant/constant.dart';
import '../../../encrypt/encrypt.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  File? img;
  @override
  Widget build(BuildContext context) {
    final myData = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("inbox"),
        centerTitle: false,
      ),
      body: ref.watch(getAllChatRooms(myData.userID)).when(
            data: (inbox) {
              return inbox.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: ListView.builder(
                        itemCount: inbox.length,
                        itemBuilder: (context, index) {
                          final chat = inbox[index];

                          return ref.watch(getUserDataProvider(chat.id!)).when(
                                data: (user) {
                                  void send() {
                                    String msg = "";
                                    if (msg.isNotEmpty || img != null) {
                                      ref
                                          .read(
                                              chatsControllerProvider.notifier)
                                          .sendMessage(
                                              chatID: chat.id!,
                                              sender: myData.userID,
                                              reciver: user.userID,
                                              myData: myData,
                                              targetUser: user,
                                              inTheChat: false,
                                              replieMessage: null,
                                              image: img,
                                              gif: null,
                                              content: msg,
                                              context: context);
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

                                  void delete() {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: const Text(
                                          "هل تريد حذف هذه المحادثه مع العلم أن الحذف قرار نهائي لايمكن استرداد البيانات مرة أخرى",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => context.pop(),
                                            child: const Text("الغاء"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.pop();
                                              ref.read(deleteChatProvider(
                                                  user.userID));
                                            },
                                            child: const Text("تأكيد"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ref
                                      .watch(getChatStatus(
                                          Tuple2(chat.id, myData.userID)))
                                      .when(
                                        data: (status) {
                                          String msg = chat.lastMessage != null
                                              ? decrypt(chat.lastMessage ?? "",
                                                  encryptKey)
                                              : "";
                                          return ref
                                              .watch(
                                                  getMembersStatus(user.userID))
                                              .when(
                                                data: (typing) {
                                                  return Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        context.push(
                                                          "/chat/${user.userID}/${chat.id}",
                                                        );
                                                        // UpdateMessagesStatus()
                                                        //     .inTheChatStatus(
                                                        //         chat.id!,
                                                        //         myData.userID);
                                                      },
                                                      splashColor:
                                                          Colors.grey[900],
                                                      highlightColor:
                                                          Colors.transparent,
                                                      child: Ink(
                                                        child: MySwipeWidget(
                                                          callback: delete,
                                                          child: ListTile(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            visualDensity:
                                                                const VisualDensity(
                                                                    horizontal:
                                                                        -4,
                                                                    vertical:
                                                                        0),
                                                            leading: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                            .grey[
                                                                        700]!),
                                                              ),
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    CachedNetworkImageProvider(
                                                                        user.profilePic),
                                                                radius: 28,
                                                              ),
                                                            ),
                                                            title: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          user.name,
                                                                          style: const TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        if (user
                                                                            .verified) ...[
                                                                          const SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          const Icon(
                                                                            Icons.verified,
                                                                            color:
                                                                                Colors.blue,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ],
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        if (typing
                                                                            .typing) ...[
                                                                          Text(
                                                                            "typing....",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                        ] else if (status.sentByMe ||
                                                                            status.lastMessageSeen) ...[
                                                                          Text(
                                                                            msg.length > 25
                                                                                ? "${msg.substring(0, 24)}..."
                                                                                : chat.lastMessage == "تم فتح المحادثة"
                                                                                    ? "تم فتح المحادثة"
                                                                                    : msg.isEmpty
                                                                                        ? "sent a picture"
                                                                                        : msg,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            " · ",
                                                                            style:
                                                                                TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                                                                          ),
                                                                          Text(
                                                                            timeago.format(chat.lastMessageDate!.toDate(), locale: 'en_short').toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                        ] else ...[
                                                                          Text(
                                                                            status.unseenMessagesCount > 1
                                                                                ? "You have ${status.unseenMessagesCount} new messages ."
                                                                                : "You have new message.",
                                                                            style: TextStyle(
                                                                                fontSize: 14,
                                                                                color: Colors.grey[200],
                                                                                fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Spacer(),
                                                                if (!(status
                                                                        .sentByMe ||
                                                                    status
                                                                        .lastMessageSeen)) ...[
                                                                  Container(
                                                                    width: 8,
                                                                    height: 8,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.blue[
                                                                            700],
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                ],
                                                                IconButton(
                                                                  onPressed:
                                                                      selectImage,
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .camera_alt_outlined),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                error: (error, trace) =>
                                                    ErrorText(
                                                        error:
                                                            error.toString()),
                                                loading: () =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey[900]!,
                                                  highlightColor:
                                                      Colors.grey[800]!,
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      radius: 28,
                                                      backgroundColor:
                                                          Colors.grey[900]!,
                                                    ),
                                                    title: const Text(
                                                        "viblify user"),
                                                    subtitle: const Text(
                                                        "Inbox Loading state here..."),
                                                  ),
                                                ),
                                              );
                                        },
                                        error: (error, trace) {
                                          log(error.toString());
                                          return ErrorText(
                                            error: error.toString(),
                                          );
                                        },
                                        loading: () => Shimmer.fromColors(
                                          baseColor: Colors.grey[900]!,
                                          highlightColor: Colors.grey[800]!,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 28,
                                              backgroundColor:
                                                  Colors.grey[900]!,
                                            ),
                                            title: const Text("viblify user"),
                                            subtitle: const Text(
                                                "Inbox Loading state here..."),
                                          ),
                                        ),
                                      );
                                },
                                error: (error, trace) {
                                  log(error.toString());
                                  return ErrorText(
                                    error: error.toString(),
                                  );
                                },
                                loading: () => Shimmer.fromColors(
                                  baseColor: Colors.grey[900]!,
                                  highlightColor: Colors.grey[800]!,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey[900]!,
                                    ),
                                    title: const Text("viblify user"),
                                    subtitle: const Text(
                                        "Inbox Loading state here..."),
                                  ),
                                ),
                              );
                        },
                      ),
                    )
                  : const MyEmptyShowen(text: "ليس لديك أي محادثات");
            },
            error: (error, trace) {
              log(error.toString());
              return ErrorText(
                error: error.toString(),
              );
            },
            loading: () => ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[900]!,
                    ),
                    title: const Text("viblify user"),
                    subtitle: const Text("Inbox Loading state here..."),
                  ),
                );
              },
            ),
          ),
    );
  }

  void myDialog(VoidCallback callback, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("هل أنت واثق من أنك تريد حذف هذه المحادثة؟\n"
            "مع العلم أن جميع البيانات و الرسائل غير قابلة للاسترجاع تحت أي ظرف من الظروف"),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("الغاء"),
          ),
          TextButton(
            onPressed: callback,
            child: const Text("نعم"),
          ),
        ],
      ),
    );
  }
}
