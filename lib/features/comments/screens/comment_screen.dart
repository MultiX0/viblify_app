import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:linkable/linkable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/Feed/tag_feed_screen.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'dart:ui' as ui;
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../../../core/methods/youtube_video_validator.dart';
import '../../../widgets/feeds_widget.dart';
import '../../stt/controller/stt_controller.dart';
import '../../user_profile/screens/video_screen.dart';
import '../widgets/comments_card.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String feedID;
  const CommentScreen({super.key, required this.feedID});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userProvider)?.userID;
    void likeHunlidng(String docID) {
      ref.watch(postControllerProvider.notifier).likeHundling(docID, uid!);
    }

    Future<bool> onLikeButtonTapped(bool isLiked, String docID) async {
      likeHunlidng(docID);
      return !isLiked;
    }

    void navigationToUserScreen(String uid, BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => UserProfileScreen(
                uid: uid,
              )),
        ),
      );
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("رجوع"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.watch(postControllerProvider.notifier).deletePost(feedID);
                },
                child: const Text("تأكيد"),
              ),
            ],
          );
        }),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: ref.watch(getFeedByID(widget.feedID)).when(
              data: (feeds) {
                final feed = feeds.first;
                return NestedScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  headerSliverBuilder: ((context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        scrolledUnderElevation: 0,
                        automaticallyImplyLeading: false,
                        primary: false,
                        pinned: true,
                        flexibleSpace: AppBar(
                          title: const Text("Comments"),
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          backgroundColor: Pallete.blackColor,
                        ),
                        backgroundColor: Pallete.blackColor,
                        elevation: 0,
                      ),
                      SliverPadding(
                        padding:
                            const EdgeInsets.only(right: 5, left: 5, top: 20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              ref.watch(getUserDataProvider(feed.userID)).when(
                                    data: (user) {
                                      final img =
                                          Uri.encodeComponent(feed.photoUrl);

                                      bool isArabic =
                                          Bidi.hasAnyRtl(feed.content);
                                      bool feedLiked = feed.likes.contains(uid);
                                      final feedTime = timeago.format(
                                          feed.createdAt.toDate(),
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
                                                  if (uid == feed.userID) ...[
                                                    ListTile(
                                                      title:
                                                          const Text("Delete"),
                                                      leading: const Icon(
                                                          Icons.delete),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        deletePost(feed.feedID);
                                                      },
                                                    ),
                                                  ]
                                                ],
                                              );
                                            });
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade900),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () => user.userID != uid
                                                  ? navigationToUserScreen(
                                                      user.userID, context)
                                                  : null,
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.black,
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
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
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          height: 20,
                                                          child: Row(
                                                            children: [
                                                              if (user
                                                                  .verified) ...[
                                                                const Icon(
                                                                  Icons
                                                                      .verified,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 14,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                              ],
                                                              GestureDetector(
                                                                onTap: () => user
                                                                            .userID !=
                                                                        uid
                                                                    ? navigationToUserScreen(
                                                                        user.userID,
                                                                        context)
                                                                    : null,
                                                                child: Text(
                                                                  user.name,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () => user
                                                                              .userID !=
                                                                          uid
                                                                      ? navigationToUserScreen(
                                                                          user.userID,
                                                                          context)
                                                                      : null,
                                                                  child: Text(
                                                                    "@${user.userName}",
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ),
                                                              ),
                                                              const Text(
                                                                " · ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              Text(
                                                                feedTime
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: more,
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .more_vert,
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
                                                    padding: EdgeInsets.only(
                                                        right: 8.0,
                                                        left: 5.0,
                                                        bottom: 8.0,
                                                        top: isArabic ? 5 : 0),
                                                    child: Align(
                                                      alignment: isArabic
                                                          ? Alignment
                                                              .centerRight
                                                          : Alignment
                                                              .centerLeft,
                                                      child: Linkable(
                                                        textColor: Colors.white,
                                                        text: feed.content,
                                                        textAlign: isArabic
                                                            ? TextAlign.right
                                                            : TextAlign.left,
                                                        textDirection: isArabic
                                                            ? ui.TextDirection
                                                                .rtl
                                                            : ui.TextDirection
                                                                .ltr,
                                                      ),
                                                    ),
                                                  ),
                                                  if (feed.tags.isNotEmpty) ...[
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Wrap(
                                                        alignment:
                                                            WrapAlignment.start,
                                                        spacing: 5.0,
                                                        runSpacing: 5.0,
                                                        children: feed.tags
                                                            .map(
                                                              (item) =>
                                                                  GestureDetector(
                                                                onTap: () =>
                                                                    navigationToTagScreen(
                                                                        item,
                                                                        context),
                                                                child: Text(
                                                                  "#$item",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                      ),
                                                    ),
                                                    if (feed.photoUrl
                                                        .isNotEmpty) ...[
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ],
                                                  if (feed.gif.isNotEmpty) ...[
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                  if (feed
                                                      .sttID.isNotEmpty) ...[
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                  if (feed
                                                      .sttID.isNotEmpty) ...[
                                                    Card(
                                                      elevation: 4.0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
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
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
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
                                                                            feed.sttID,
                                                                            feed.userID),
                                                                      ),
                                                                    )
                                                                    .when(
                                                                      data: (stt) =>
                                                                          Text(
                                                                        stt.first
                                                                            .message,
                                                                        textDirection: Bidi.hasAnyRtl(stt.first.message)
                                                                            ? ui.TextDirection.rtl
                                                                            : ui.TextDirection.ltr,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      error: (error,
                                                                              trace) =>
                                                                          ErrorText(
                                                                              error: error.toString()),
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
                                                  if (feed.youtubeVideoID
                                                      .isNotEmpty) ...[
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                  if (feed.gif.isNotEmpty) ...[
                                                    GestureDetector(
                                                      onDoubleTap: () =>
                                                          likeHunlidng(
                                                              feed.feedID),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                bottom: 5,
                                                                right: 5,
                                                                left: 3),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                15.0),
                                                          ),
                                                          child: ExtendedImage
                                                              .network(
                                                            feed.gif,
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
                                                                      highlightColor: Colors
                                                                          .grey
                                                                          .shade800,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
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
                                                                    fit: BoxFit
                                                                        .cover,
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
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (feed.youtubeVideoID
                                                      .isNotEmpty) ...[
                                                    AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          image:
                                                              DecorationImage(
                                                                  image:
                                                                      NetworkImage(
                                                                    VideoURLValidator
                                                                        .getYouTubeThumbnail(
                                                                            feed.youtubeVideoID),
                                                                  ),
                                                                  fit: BoxFit
                                                                      .cover),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                navigationToVideScreen(
                                                                    feed.youtubeVideoID,
                                                                    context),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2.5),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .play_circle,
                                                                color: Colors
                                                                    .white,
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
                                                  if (feed
                                                      .photoUrl.isNotEmpty) ...[
                                                    Hero(
                                                      tag: feed
                                                          .photoUrl, // Ensure this tag is unique and consistent
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(10.0),
                                                        ),
                                                        child: GestureDetector(
                                                          onDoubleTap: () =>
                                                              likeHunlidng(
                                                                  feed.feedID),
                                                          child: ExtendedImage
                                                              .network(
                                                            feed.photoUrl,
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
                                                                      highlightColor: Colors
                                                                          .grey
                                                                          .shade800,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          color: Colors
                                                                              .grey
                                                                              .shade900,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );

                                                                case LoadState
                                                                      .completed:
                                                                  return GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.of(context)
                                                                            .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            ((context) =>
                                                                                ImageSlidePage(imageUrl: img)),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ExtendedRawImage(
                                                                      image: state
                                                                          .extendedImageInfo
                                                                          ?.image,
                                                                    ),
                                                                  );

                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                            cache: true,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  ref
                                                      .watch(getFeedByID(
                                                          feed.feedID))
                                                      .when(
                                                        data: (feeds) {
                                                          final feed =
                                                              feeds.first;
                                                          bool feedLiked = feed
                                                              .likes
                                                              .contains(uid);

                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                right: 15,
                                                                bottom: feed
                                                                        .photoUrl
                                                                        .isEmpty
                                                                    ? 5
                                                                    : 10,
                                                                top: feed
                                                                        .photoUrl
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
                                                                      onTap: (isLiked) => onLikeButtonTapped(
                                                                          isLiked,
                                                                          feed.feedID),
                                                                      likeBuilder:
                                                                          (bool
                                                                              isLiked) {
                                                                        return Icon(
                                                                          feedLiked
                                                                              ? Icons.favorite
                                                                              : Icons.favorite_border,
                                                                          color: feedLiked
                                                                              ? Colors.pinkAccent
                                                                              : Colors.grey.shade800,
                                                                          size:
                                                                              19,
                                                                        );
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            6.0),
                                                                    AnimatedSwitcher(
                                                                      duration: const Duration(
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
                                                                      child:
                                                                          Text(
                                                                        feed.likes
                                                                            .length
                                                                            .toString(),
                                                                        key: ValueKey<int>(feed
                                                                            .likes
                                                                            .length),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .chat_bubble_outline,
                                                                      color: feed.isCommentsOpen
                                                                          ? Colors
                                                                              .grey
                                                                              .shade700
                                                                          : Colors
                                                                              .grey
                                                                              .shade800
                                                                              .withOpacity(0.6),
                                                                      size:
                                                                          18.0,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            6.0),
                                                                    Text(
                                                                      feed.commentCount
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      LineIcons
                                                                          .share,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade700,
                                                                      size:
                                                                          18.0,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            6.0),
                                                                    const Text(
                                                                      '0',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .stacked_bar_chart_rounded,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade700,
                                                                      size:
                                                                          18.0,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            6.0),
                                                                    Text(
                                                                      feed.views
                                                                          .length
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        error: (error, trace) =>
                                                            ErrorText(
                                                          error:
                                                              error.toString(),
                                                        ),
                                                        loading: () => Padding(
                                                          padding: EdgeInsets.only(
                                                              right: 15,
                                                              bottom: feed
                                                                      .photoUrl
                                                                      .isEmpty
                                                                  ? 5
                                                                  : 10,
                                                              top: feed.photoUrl
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
                                                                    likeBuilder:
                                                                        (bool
                                                                            isLiked) {
                                                                      return Icon(
                                                                        feedLiked
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_border,
                                                                        color: feedLiked
                                                                            ? Colors.pinkAccent
                                                                            : Colors.grey.shade800,
                                                                        size:
                                                                            19,
                                                                      );
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          6.0),
                                                                  AnimatedSwitcher(
                                                                    duration: const Duration(
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
                                                                      key: ValueKey<int>(feed
                                                                          .likes
                                                                          .length),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .chat_bubble_outline,
                                                                    color: feed
                                                                            .isCommentsOpen
                                                                        ? Colors
                                                                            .grey
                                                                            .shade700
                                                                        : Colors
                                                                            .grey
                                                                            .shade800
                                                                            .withOpacity(0.6),
                                                                    size: 18.0,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          6.0),
                                                                  Text(
                                                                      feed.commentCount
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey)),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    LineIcons
                                                                        .share,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700,
                                                                    size: 18.0,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          6.0),
                                                                  const Text(
                                                                    '0',
                                                                    style: TextStyle(
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
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700,
                                                                    size: 18.0,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          6.0),
                                                                  Text(
                                                                      feed.views
                                                                          .length
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.grey)),
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
                                      );
                                    },
                                    error: (error, trace) =>
                                        ErrorText(error: error.toString()),
                                    loading: () => const Skeletonizer(
                                      enabled: true,
                                      child: Card(
                                        child: ListTile(
                                          title: Text('Item number 1 as title'),
                                          subtitle: Text('Subtitle here'),
                                          leading: Icon(Icons.ac_unit),
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      )
                    ];
                  }),
                  body: CommentsCard(
                    feedID: widget.feedID,
                    feedUserID: feed.userID,
                  ),
                );
              },
              error: (error, trace) {
                print(error);
                return const Center(
                  child: Text("المنشور الذي تبحث عنه غير موجود"),
                );
              },
              loading: () => const Loader(),
            ),
      ),
    );
  }

  void navigationToTagScreen(String tag, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => TagFeedsScreen(tag: tag)),
      ),
    );
  }

  void navigationToUserScreen(String uid, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => UserProfileScreen(
              uid: uid,
            )),
      ),
    );
  }
}

void navigationToVideScreen(String videoID, BuildContext context) async {
  final title = await VideoURLValidator.getVideoTitle(videoID) ?? "";
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VideoScreen(id: videoID, nameOfVideo: title),
    ),
  );
}
