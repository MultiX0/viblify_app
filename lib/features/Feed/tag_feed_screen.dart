import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:linkable/linkable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui' as ui;

class TagFeedsScreen extends ConsumerStatefulWidget {
  final String tag;
  const TagFeedsScreen({super.key, required this.tag});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<TagFeedsScreen> {
  String query = '';
  late TextEditingController search;
  @override
  void initState() {
    query = widget.tag;
    search = TextEditingController(text: widget.tag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    final myID = ref.watch(userProvider)!.userID;
    void likeHunlidng(String docID) {
      ref.watch(postControllerProvider.notifier).likeHundling(docID, myID);
    }

    Future<bool> onLikeButtonTapped(bool isLiked, String docID) async {
      likeHunlidng(docID);
      return !isLiked;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.blackColor,
        elevation: 0,
        title: Row(
          children: [
            const Text("Viblify"),
            const SizedBox(
              width: 25,
            ),
            Expanded(
              child: TextField(
                controller: search,
                onChanged: (val) {
                  setState(() {
                    query = val;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  prefixIconColor: Colors.white,
                  hintText: 'Search Viblify',
                  hintStyle: const TextStyle(color: Colors.white, fontFamily: "LobsterTwo"),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ref
          .watch(
            getFeedsByTagsProvider(query != widget.tag ? query : widget.tag),
          )
          .when(
            data: (posts) => ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ref.watch(getUserDataProvider(post.userID)).when(
                    data: (user) {
                      void viewDocument() {
                        ref.watch(postControllerProvider.notifier).viewDocument(post.feedID, myID);
                      }

                      bool postLiked = post.likes.contains(myID);

                      bool isArabic = Bidi.hasAnyRtl(post.content);
                      final postTime = timeago.format(
                          Timestamp.fromMillisecondsSinceEpoch(int.parse(post.createdAt)).toDate(),
                          locale: 'en_short');
                      return Focus(
                        focusNode: focusNode,
                        child: Listener(
                          onPointerHover: (event) => viewDocument(),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade900),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.black,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(user.profilePic),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 5),
                                              height: 20,
                                              child: Row(
                                                children: [
                                                  if (user.verified) ...[
                                                    const Icon(
                                                      Icons.verified,
                                                      color: Colors.blue,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                  Text(
                                                    user.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5.0),
                                                    child: Text(
                                                      "@${user.userName}",
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                  const Text(
                                                    " · ",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                                                  ),
                                                  Text(
                                                    postTime.toString(),
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.more_vert,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 8.0, left: 5.0, bottom: 8.0, top: isArabic ? 5 : 0),
                                        child: Align(
                                          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                                          child: Linkable(
                                            text: post.content,
                                            textColor: Colors.white,
                                            textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                          ),
                                        ),
                                      ),
                                      if (post.tags.isNotEmpty) ...[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: post.tags
                                                .map((item) => GestureDetector(
                                                      onTap: () {
                                                        if (query != item) {
                                                          print(item);
                                                          navigationToTagScreen(item, context);
                                                        }
                                                      },
                                                      child: Text(
                                                        "#$item",
                                                        style: const TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w600),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                        if (post.photoUrl.isNotEmpty) ...[
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ],
                                      if (post.photoUrl.isNotEmpty) ...[
                                        Hero(
                                          tag: post.photoUrl, // Ensure this tag is unique and consistent
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            child: ExtendedImage.network(post.photoUrl,
                                                loadStateChanged: (ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                  return AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors.grey.shade900,
                                                      highlightColor: Colors.grey.shade800,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.grey.shade900,
                                                        ),
                                                      ),
                                                    ),
                                                  );

                                                case LoadState.completed:
                                                  return GestureDetector(
                                                    onTap: () => context.push(
                                                      "/img/slide/${base64UrlEncode(utf8.encode(post.photoUrl))}",
                                                    ),
                                                    child: ExtendedRawImage(
                                                      image: state.extendedImageInfo?.image,
                                                    ),
                                                  );

                                                default:
                                                  return null;
                                              }
                                            }, cache: true, borderRadius: BorderRadius.circular(0)),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 15,
                                              bottom: post.photoUrl.isEmpty ? 5 : 10,
                                              top: post.photoUrl.isEmpty ? 10 : 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  LikeButton(
                                                    size: 19,
                                                    onTap: (isLiked) => onLikeButtonTapped(isLiked, post.feedID),
                                                    likeBuilder: (bool isLiked) {
                                                      return Icon(
                                                        postLiked ? Icons.favorite : Icons.favorite_border,
                                                        color: postLiked ? Colors.pinkAccent : Colors.grey.shade800,
                                                        size: 19,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    transitionBuilder: (child, animation) {
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      );
                                                    },
                                                    child: Text(
                                                      post.likes.length.toString(),
                                                      key: ValueKey<int>(post.likes.length),
                                                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.chat_bubble_outline,
                                                    color: Colors.grey.shade800,
                                                    size: 18.0,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(post.commentCount.toString(),
                                                      style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    LineIcons.share,
                                                    color: Colors.grey.shade800,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  const Text(
                                                    '0',
                                                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.stacked_bar_chart_rounded,
                                                    color: Colors.grey.shade800,
                                                    size: 18.0,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(post.views.length.toString(),
                                                      style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    error: (error, trace) => ErrorText(error: error.toString()),
                    loading: () => const Loader());
              },
            ),
            error: (error, trace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }

  void navigationToTagScreen(String tag, BuildContext context) {
    setState(() {
      query = tag;
      search = TextEditingController(text: tag);
    });
  }
}
