// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:linkable/linkable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/core/methods/youtube_video_validator.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/features/stt/controller/stt_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';
import 'dart:ui' as ui;
import '../features/auth/controller/auth_controller.dart';
import '../models/feeds_model.dart';

class FeedsWidget extends ConsumerWidget {
  final List<Feeds> posts;
  final bool isThemeDark;
  final String dividerColor;
  final bool isUserProfile;
  const FeedsWidget(
      {super.key,
      required this.posts,
      required this.isThemeDark,
      required this.dividerColor,
      required this.isUserProfile});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FocusNode focusNode = FocusNode();
    final myID = ref.watch(userProvider)!.userID;
    void likeHunlidng(String docID) {
      ref.watch(postControllerProvider.notifier).likeHundling(docID, myID);
    }

    Future<bool> onLikeButtonTapped(bool isLiked, String docID) async {
      likeHunlidng(docID);
      return !isLiked;
    }

    void deletePost(String feedID) {
      showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("هل تريد حذف المنشور؟"),
            content: const Text(
                "هل أنت متأكد من رغبتك في حذف هذا المنشور , مع العلم أن قرار الحذف نهائي ولا يتم الرجوع فيه"),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("رجوع"),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  ref.watch(postControllerProvider.notifier).deletePost(feedID);
                },
                child: const Text("تأكيد"),
              ),
            ],
          );
        }),
      );
    }

    bool hasAnyShowed = posts.any((post) => post.isShowed);

    return (posts.isNotEmpty && hasAnyShowed)
        ? ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              void commentScreen() {
                context.push(
                  "/p/${post.feedID}",
                );
              }

              return post.isShowed
                  ? ref.watch(getUserDataProvider(post.userID)).when(
                        data: (user) {
                          void viewDocument() {
                            ref
                                .watch(postControllerProvider.notifier)
                                .viewDocument(post.feedID, myID);
                          }

                          bool isArabic = Bidi.hasAnyRtl(post.content);
                          bool feedLiked = post.likes.contains(myID);
                          final postTime = timeago.format(
                              Timestamp.fromMillisecondsSinceEpoch(
                                      int.parse(post.createdAt))
                                  .toDate(),
                              locale: 'en_short');
                          void more() {
                            showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                isScrollControlled: false,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (myID == post.userID) ...[
                                        ListTile(
                                          title: const Text("حذف المنشور"),
                                          leading: const Icon(Icons.delete),
                                          onTap: () {
                                            context.pop();
                                            deletePost(post.feedID);
                                          },
                                        ),
                                      ],
                                      ListTile(
                                          title: const Text("نسخ الرابط"),
                                          leading: const Icon(Icons.link),
                                          onTap: () {
                                            copyPostUrl(
                                              post.feedID,
                                              ref,
                                            );
                                            context.pop();
                                          }),
                                    ],
                                  );
                                });
                          }

                          return Focus(
                            focusNode: focusNode,
                            child: Listener(
                              onPointerHover: (event) => viewDocument(),
                              child: GestureDetector(
                                onLongPress: () {
                                  if (post.isCommentsOpen != false) {
                                    commentScreen();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'التعليقات مغلقة لهذا المنشور');
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: dividerColor.isEmpty
                                            ? Colors.grey.shade900
                                            : HexColor(dividerColor),
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () => user.userID != myID
                                            ? navigationToUserScreen(
                                                user.userID, context)
                                            : null,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black,
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    user.profilePic),
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    height: 20,
                                                    child: Row(
                                                      children: [
                                                        if (user.verified) ...[
                                                          Icon(
                                                            Icons.verified,
                                                            color: isThemeDark
                                                                ? Colors.blue
                                                                : Colors.black,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                        GestureDetector(
                                                          onTap: () => user
                                                                      .userID !=
                                                                  myID
                                                              ? navigationToUserScreen(
                                                                  user.userID,
                                                                  context)
                                                              : null,
                                                          child: Text(
                                                            user.name,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: isThemeDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () => user
                                                                        .userID !=
                                                                    myID
                                                                ? navigationToUserScreen(
                                                                    user.userID,
                                                                    context)
                                                                : null,
                                                            child: Text(
                                                              "@${user.userName}",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                  color: isThemeDark
                                                                      ? Colors
                                                                          .grey
                                                                      : Colors.grey[
                                                                          900]),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          " · ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color: isThemeDark
                                                                  ? Colors.grey
                                                                  : Colors.grey[
                                                                      900]),
                                                        ),
                                                        Text(
                                                          postTime.toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color: isThemeDark
                                                                  ? Colors.grey
                                                                  : Colors.grey[
                                                                      900]),
                                                        ),
                                                        const Spacer(),
                                                        IconButton(
                                                          onPressed: more,
                                                          icon: Icon(
                                                            Icons.more_vert,
                                                            size: 14,
                                                            color: isThemeDark
                                                                ? Colors.grey
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  left: 5.0,
                                                  bottom: 8.0,
                                                  top: isArabic ? 5 : 0),
                                              child: Align(
                                                alignment: isArabic
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                child: Linkable(
                                                  textColor: isThemeDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  linkColor: isThemeDark
                                                      ? Colors.blue
                                                      : Colors.blue[900],
                                                  text: post.content,
                                                  style: TextStyle(
                                                      fontWeight: isThemeDark
                                                          ? null
                                                          : FontWeight.bold),
                                                  textAlign: isArabic
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                                  textDirection: isArabic
                                                      ? ui.TextDirection.rtl
                                                      : ui.TextDirection.ltr,
                                                ),
                                              ),
                                            ),
                                            if (post.tags.isNotEmpty) ...[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.start,
                                                  spacing: 5.0,
                                                  runSpacing: 5.0,
                                                  children: post.tags
                                                      .map(
                                                        (item) =>
                                                            GestureDetector(
                                                          onTap: () =>
                                                              navigationToTagScreen(
                                                                  item,
                                                                  context),
                                                          child: Text(
                                                            "#$item",
                                                            style: TextStyle(
                                                                color: isThemeDark
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors.blue[
                                                                        900],
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                              if (post.photoUrl.isNotEmpty) ...[
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ],
                                            if (post.gif.isNotEmpty) ...[
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                            if (post.sttID.isNotEmpty) ...[
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                            if (post.sttID.isNotEmpty) ...[
                                              Card(
                                                elevation: 4.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Center(
                                                      child: Text(
                                                        "viblify/stt",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                "LobsterTwo",
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 16,
                                                              bottom: 16,
                                                              top: 8),
                                                      child: Column(
                                                        children: [
                                                          ref
                                                              .watch(
                                                                getSttByIdProvider(
                                                                  Tuple2(
                                                                      post.sttID,
                                                                      post.userID),
                                                                ),
                                                              )
                                                              .when(
                                                                data: (stt) =>
                                                                    Text(
                                                                  stt.first
                                                                      .message,
                                                                  textDirection: Bidi.hasAnyRtl(stt
                                                                          .first
                                                                          .message)
                                                                      ? ui.TextDirection
                                                                          .rtl
                                                                      : ui.TextDirection
                                                                          .ltr,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                error: (error,
                                                                        trace) =>
                                                                    ErrorText(
                                                                        error: error
                                                                            .toString()),
                                                                loading: () =>
                                                                    const SttLoadingWidget(),
                                                              ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            if (post
                                                .youtubeVideoID.isNotEmpty) ...[
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                            if (post.gif.isNotEmpty) ...[
                                              GestureDetector(
                                                onDoubleTap: () =>
                                                    likeHunlidng(post.feedID),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5,
                                                          bottom: 5,
                                                          right: 5,
                                                          left: 3),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(15.0),
                                                    ),
                                                    child:
                                                        ExtendedImage.network(
                                                      post.gif,
                                                      fit: BoxFit.cover,
                                                      loadStateChanged:
                                                          (ExtendedImageState
                                                              state) {
                                                        switch (state
                                                            .extendedImageLoadState) {
                                                          case LoadState
                                                                .loading:
                                                            return AspectRatio(
                                                              aspectRatio:
                                                                  16 / 9,
                                                              child: Shimmer
                                                                  .fromColors(
                                                                baseColor: Colors
                                                                    .grey
                                                                    .shade900,
                                                                highlightColor:
                                                                    Colors.grey
                                                                        .shade800,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade900,
                                                                  ),
                                                                ),
                                                              ),
                                                            );

                                                          case LoadState
                                                                .completed:
                                                            return ExtendedRawImage(
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                              image: state
                                                                  .extendedImageInfo
                                                                  ?.image,
                                                            );

                                                          default:
                                                            return null;
                                                        }
                                                      },
                                                      cache: true,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (post
                                                .youtubeVideoID.isNotEmpty) ...[
                                              AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    image: DecorationImage(
                                                        image:
                                                            CachedNetworkImageProvider(
                                                          VideoURLValidator
                                                              .getYouTubeThumbnail(
                                                                  post.youtubeVideoID),
                                                        ),
                                                        fit: BoxFit.cover),
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          navigationToVideScreen(
                                                              post.youtubeVideoID,
                                                              context),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2.5),
                                                        ),
                                                        child: const Icon(
                                                          Icons.play_circle,
                                                          color: Colors.white,
                                                          size: 45,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                            if (post.photoUrl.isNotEmpty) ...[
                                              Hero(
                                                tag: post
                                                    .photoUrl, // Ensure this tag is unique and consistent
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  child: GestureDetector(
                                                    onDoubleTap: () =>
                                                        likeHunlidng(
                                                            post.feedID),
                                                    child: CachedNetworkImage(
                                                      imageUrl: post.photoUrl,
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return GestureDetector(
                                                          onTap: () =>
                                                              context.push(
                                                            "/img/slide/${base64UrlEncode(utf8.encode(post.photoUrl))}",
                                                          ),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            constraints: BoxConstraints(
                                                                maxHeight:
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width),
                                                            child: Image(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      placeholder:
                                                          (context, url) {
                                                        return AspectRatio(
                                                          aspectRatio: 1 / 1,
                                                          child: Shimmer
                                                              .fromColors(
                                                            baseColor: Colors
                                                                .grey.shade900,
                                                            highlightColor:
                                                                Colors.grey
                                                                    .shade800,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                color: Colors
                                                                    .grey
                                                                    .shade900,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            ref
                                                .watch(getFeedByID(post.feedID))
                                                .when(
                                                  data: (feeds) {
                                                    final feed = feeds.first;
                                                    bool postLiked = feed.likes
                                                        .contains(myID);

                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 15,
                                                          bottom: post.photoUrl
                                                                  .isEmpty
                                                              ? 5
                                                              : 10,
                                                          top: post.photoUrl
                                                                  .isEmpty
                                                              ? 10
                                                              : 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              LikeButton(
                                                                size: 19,
                                                                onTap: (isLiked) =>
                                                                    onLikeButtonTapped(
                                                                        isLiked,
                                                                        feed.feedID),
                                                                likeBuilder: (bool
                                                                    isLiked) {
                                                                  return Icon(
                                                                    postLiked
                                                                        ? Icons
                                                                            .favorite
                                                                        : Icons
                                                                            .favorite_border,
                                                                    color: postLiked
                                                                        ? Colors.pinkAccent
                                                                        : isThemeDark
                                                                            ? Colors.grey.shade800
                                                                            : Colors.black,
                                                                    size: 19,
                                                                  );
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  width: 6.0),
                                                              AnimatedSwitcher(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                transitionBuilder:
                                                                    (child,
                                                                        animation) {
                                                                  return FadeTransition(
                                                                    opacity:
                                                                        animation,
                                                                    child:
                                                                        child,
                                                                  );
                                                                },
                                                                child: Text(
                                                                  feed.likes
                                                                      .length
                                                                      .toString(),
                                                                  key: ValueKey<
                                                                          int>(
                                                                      feed.likes
                                                                          .length),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      color: isThemeDark
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          GestureDetector(
                                                            onTap: feed
                                                                    .isCommentsOpen
                                                                ? commentScreen
                                                                : () => Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            "التعليقات مغلقة لهذا المنشور"),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .chat_bubble_outline,
                                                                  color: feed
                                                                          .isCommentsOpen
                                                                      ? isThemeDark
                                                                          ? Colors
                                                                              .grey
                                                                              .shade700
                                                                          : Colors
                                                                              .black
                                                                      : isThemeDark
                                                                          ? Colors
                                                                              .grey
                                                                              .shade800
                                                                              .withOpacity(0.6)
                                                                          : Colors.grey[900],
                                                                  size: 18.0,
                                                                ),
                                                                const SizedBox(
                                                                    width: 6.0),
                                                                Text(
                                                                  feed.commentCount
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      color: isThemeDark
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () =>
                                                                copyPostUrl(
                                                              feed.feedID,
                                                              ref,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  LineIcons
                                                                      .share,
                                                                  color: isThemeDark
                                                                      ? Colors
                                                                          .grey
                                                                          .shade700
                                                                      : Colors
                                                                          .black,
                                                                  size: 18.0,
                                                                ),
                                                                const SizedBox(
                                                                    width: 6.0),
                                                                Text(
                                                                  feed.shares
                                                                      .length
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      color: isThemeDark
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .stacked_bar_chart_rounded,
                                                                color: isThemeDark
                                                                    ? Colors
                                                                        .grey
                                                                        .shade700
                                                                    : Colors
                                                                        .black,
                                                                size: 18.0,
                                                              ),
                                                              const SizedBox(
                                                                  width: 6.0),
                                                              Text(
                                                                feed.views
                                                                    .length
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    color: isThemeDark
                                                                        ? Colors
                                                                            .grey
                                                                        : Colors
                                                                            .black),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  error: (error, trace) =>
                                                      ErrorText(
                                                    error: error.toString(),
                                                  ),
                                                  loading: () => Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 15,
                                                        bottom: post.photoUrl
                                                                .isEmpty
                                                            ? 5
                                                            : 10,
                                                        top: post.photoUrl
                                                                .isEmpty
                                                            ? 10
                                                            : 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            LikeButton(
                                                              size: 19,
                                                              onTap: (isLiked) =>
                                                                  onLikeButtonTapped(
                                                                      isLiked,
                                                                      post.feedID),
                                                              likeBuilder: (bool
                                                                  isLiked) {
                                                                return Icon(
                                                                  feedLiked
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: feedLiked
                                                                      ? Colors
                                                                          .pinkAccent
                                                                      : Colors
                                                                          .grey
                                                                          .shade800,
                                                                  size: 19,
                                                                );
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                width: 6.0),
                                                            AnimatedSwitcher(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              transitionBuilder:
                                                                  (child,
                                                                      animation) {
                                                                return FadeTransition(
                                                                  opacity:
                                                                      animation,
                                                                  child: child,
                                                                );
                                                              },
                                                              child: Text(
                                                                post.likes
                                                                    .length
                                                                    .toString(),
                                                                key: ValueKey<
                                                                        int>(
                                                                    post.likes
                                                                        .length),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .chat_bubble_outline,
                                                              color: post
                                                                      .isCommentsOpen
                                                                  ? Colors.grey
                                                                      .shade700
                                                                  : Colors.grey
                                                                      .shade800
                                                                      .withOpacity(
                                                                          0.6),
                                                              size: 18.0,
                                                            ),
                                                            const SizedBox(
                                                                width: 6.0),
                                                            Text(
                                                                post.commentCount
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    color: Colors
                                                                        .grey)),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              LineIcons.share,
                                                              color: Colors.grey
                                                                  .shade700,
                                                              size: 18.0,
                                                            ),
                                                            const SizedBox(
                                                                width: 6.0),
                                                            Text(
                                                              post.shares.length
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .stacked_bar_chart_rounded,
                                                              color: Colors.grey
                                                                  .shade700,
                                                              size: 18.0,
                                                            ),
                                                            const SizedBox(
                                                                width: 6.0),
                                                            Text(
                                                                post.views
                                                                    .length
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    color: Colors
                                                                        .grey)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        error: (error, trace) =>
                            ErrorText(error: error.toString()),
                        loading: () => Skeletonizer(
                          enabled: true,
                          child: Card(
                            child: ListTile(
                              title: Text('Item number $index as title'),
                              subtitle: const Text('Subtitle here'),
                              leading: const Icon(Icons.ac_unit),
                            ),
                          ),
                        ),
                      )
                  : const SizedBox();
            },
          )
        : const MyEmptyShowen(text: "لاتوجد اي مناشير");
  }

  void navigationToVideScreen(String videoID, BuildContext context) async {
    final title = await VideoURLValidator.getVideoTitle(videoID) ?? "";
    context.push(
      "/video/$videoID/$title",
    );
  }

  void navigationToTagScreen(String tag, BuildContext context) {
    context.push(
      "/tag/$tag",
    );
  }

  void navigationToUserScreen(String uid, BuildContext context) {
    if (isUserProfile != true) {
      context.push('/u/$uid');
    } else {
      log("this is the user profile");
    }
  }
}

class SttLoadingWidget extends StatelessWidget {
  const SttLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Card(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const ListTile(
            title: Text('here is text of the loading screen say hi'),
            subtitle: Text('Subtitle here'),
          ),
        ),
      ),
    );
  }
}
