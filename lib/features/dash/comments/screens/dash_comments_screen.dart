// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/widgets/empty_widget.dart';

import '../../../../utils/my_model_bottom_sheet.dart';
import '../controller/controller.dart';

TextEditingController comments = TextEditingController();

class DashCommentsScreen extends ConsumerStatefulWidget {
  final String dashID;
  final String dashUserID;
  const DashCommentsScreen({super.key, required this.dashID, required this.dashUserID});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashCommentsScreenState();
}

class _DashCommentsScreenState extends ConsumerState<DashCommentsScreen> {
  @override
  void initState() {
    ref.refresh(getDashCommentsProvider(widget.dashID));
    super.initState();
  }

  void reloadComments() {
    Timer(const Duration(milliseconds: 500), () {
      ref.refresh(getDashCommentsProvider(widget.dashID));
    });
  }

  @override
  Widget build(BuildContext context) {
    final myData = ref.read(userProvider)!;
    void addComment() async {
      if (comments.text.trim().isNotEmpty) {
        ref.read(dashCommentsControllerProvider.notifier).addComment(
              content: comments.text.trim(),
              context: context,
              dashID: widget.dashID,
              dashUserID: widget.dashUserID,
              ref: ref,
            );

        comments.clear();
      }
    }

    void likeHunlidng(String commentID) {
      ref
          .watch(dashCommentsControllerProvider.notifier)
          .likeHundling(commentID, myData.userID, widget.dashID);
    }

    Future<bool> onLikeButtonTapped(bool isLiked, String docID) async {
      likeHunlidng(docID);
      return !isLiked;
    }

    void more(String commentID) {
      moreData(
        context: context,
        onTap: () {
          context.pop();
          ref
              .read(dashCommentsControllerProvider.notifier)
              .deleteComment(commentID, widget.dashID, context)
              .then((e) => reloadComments());
          ref.refresh(getDashCommentsProvider(widget.dashID));

          ref.refresh(getDashCommentsProvider(widget.dashID));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dash Comments"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ref.watch(getDashCommentsProvider(widget.dashID)).when(
                  data: (comments) {
                    return (comments.isNotEmpty)
                        ? ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              DateTime dateTime = DateTime.parse(comment.createdAt.toString());

                              final createdAt = timeago.format(dateTime, locale: 'en');
                              bool commentLiked = comment.likes.contains(myData.userID);
                              return ref.read(getUserDataProvider(comment.userID)).when(
                                  data: (user) {
                                    return comment.userID.isEmpty
                                        ? null
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      DenscordColors.scaffoldForeground,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(user.profilePic),
                                                  radius: 18,
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "@${user.userName}",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey[500],
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            ' ∘ ',
                                                            style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 13),
                                                          ),
                                                          Text(
                                                            createdAt,
                                                            style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 13),
                                                          ),
                                                          const Spacer(),
                                                          GestureDetector(
                                                            onTap: () => more(comment.commentID),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Icon(
                                                                Icons.more_horiz,
                                                                color: Colors.grey[700],
                                                                size: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        comment.content,
                                                        style: const TextStyle(fontSize: 13),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: ref
                                                            .watch(getDashCommentByID(
                                                                comment.commentID))
                                                            .when(
                                                              data: (data) {
                                                                return data.userID.isNotEmpty
                                                                    ? Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          LikeButton(
                                                                            size: 19,
                                                                            onTap: (isLiked) =>
                                                                                onLikeButtonTapped(
                                                                                    data.likes.contains(
                                                                                        myData
                                                                                            .userID),
                                                                                    data.commentID),
                                                                            likeBuilder:
                                                                                (bool isLiked) {
                                                                              return Icon(
                                                                                data.likes.contains(
                                                                                        myData
                                                                                            .userID)
                                                                                    ? Icons.favorite
                                                                                    : Icons
                                                                                        .favorite_border,
                                                                                color: data.likes
                                                                                        .contains(myData
                                                                                            .userID)
                                                                                    ? Colors
                                                                                        .pinkAccent
                                                                                    : Colors
                                                                                        .grey[600],
                                                                                size: 19,
                                                                              );
                                                                            },
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 3,
                                                                          ),
                                                                          Text(
                                                                            data.likes.length
                                                                                .toString(),
                                                                            style: TextStyle(
                                                                                color: Colors
                                                                                    .grey[700],
                                                                                fontSize: 13),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : null;
                                                              },
                                                              error: (error, trace) => null,
                                                              loading: () => Row(
                                                                children: [
                                                                  LikeButton(
                                                                    size: 19,
                                                                    onTap: (isLiked) =>
                                                                        onLikeButtonTapped(isLiked,
                                                                            comment.commentID),
                                                                    likeBuilder: (bool isLiked) {
                                                                      return Icon(
                                                                        commentLiked
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_border,
                                                                        color: commentLiked
                                                                            ? Colors.pinkAccent
                                                                            : Colors.grey[600],
                                                                        size: 19,
                                                                      );
                                                                    },
                                                                  ),
                                                                  Text(
                                                                    comment.likes.length.toString(),
                                                                    style: TextStyle(
                                                                        color: Colors.grey[700],
                                                                        fontSize: 13),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                  },
                                  error: (error, trace) => ErrorText(
                                        error: error.toString(),
                                      ),
                                  loading: () => const Loader());
                            },
                          )
                        : const MyEmptyShowen(text: "No Comments Yet");
                  },
                  error: (error, trace) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    cursorColor: const Color(0xFF0D47A1),
                    cursorHeight: 25,
                    controller: comments,
                    style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 13),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      alignLabelWithHint: true,
                      hintStyle: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 13),
                      hintText: "كتابة تعليق",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
