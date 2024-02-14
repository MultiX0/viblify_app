import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:linkable/linkable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/features/Feed/tag_feed_screen.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';
import 'dart:ui' as ui;
import '../features/auth/controller/auth_controller.dart';
import '../features/comments/screens/comment_screen.dart';
import '../models/feeds_model.dart';

class FeedsWidget extends ConsumerWidget {
  final List<Feeds> posts;
  const FeedsWidget({super.key, required this.posts});
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

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        void commentScreen() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => CommentScreen(feedID: post.feedID)),
            ),
          );
        }

        return ref.watch(getUserDataProvider(post.userID)).when(
              data: (user) {
                void viewDocument() {
                  ref
                      .watch(postControllerProvider.notifier)
                      .viewDocument(post.feedID, myID);
                }

                final img = Uri.encodeComponent(post.photoUrl);

                bool isArabic = Bidi.hasAnyRtl(post.content);
                bool feedLiked = post.likes.contains(myID);
                final postTime =
                    timeago.format(post.createdAt.toDate(), locale: 'en_short');
                return Focus(
                  focusNode: focusNode,
                  child: Listener(
                    onPointerHover: (event) => viewDocument(),
                    child: InkWell(
                      onTap: commentScreen,
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
                            GestureDetector(
                              onTap: () => user.userID != myID
                                  ? navigationToUserScreen(user.userID, context)
                                  : null,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
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
                                              const EdgeInsets.only(left: 5),
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
                                              GestureDetector(
                                                onTap: () => user.userID != myID
                                                    ? navigationToUserScreen(
                                                        user.userID, context)
                                                    : null,
                                                child: Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: GestureDetector(
                                                  onTap: () => user.userID !=
                                                          myID
                                                      ? navigationToUserScreen(
                                                          user.userID, context)
                                                      : null,
                                                  child: Text(
                                                    "@${user.userName}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                              const Text(
                                                " · ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey),
                                              ),
                                              Text(
                                                postTime.toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey),
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
                                        textColor: Colors.white,
                                        text: post.content,
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
                                        alignment: WrapAlignment.start,
                                        spacing: 5.0,
                                        runSpacing: 5.0,
                                        children: post.tags
                                            .map(
                                              (item) => GestureDetector(
                                                onTap: () =>
                                                    navigationToTagScreen(
                                                        item, context),
                                                child: Text(
                                                  "#$item",
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
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
                                  if (post.photoUrl.isNotEmpty) ...[
                                    Hero(
                                      tag: post
                                          .photoUrl, // Ensure this tag is unique and consistent
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        child: ExtendedImage.network(
                                          post.photoUrl,
                                          loadStateChanged:
                                              (ExtendedImageState state) {
                                            switch (
                                                state.extendedImageLoadState) {
                                              case LoadState.loading:
                                                return AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade900,
                                                    highlightColor:
                                                        Colors.grey.shade800,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                );

                                              case LoadState.completed:
                                                return GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: ((context) =>
                                                          ImageSlidePage(
                                                              imageUrl: img)),
                                                    ),
                                                  ),
                                                  child: ExtendedRawImage(
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
                                              BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                  ],
                                  ref.watch(getFeedByID(post.feedID)).when(
                                        data: (feeds) {
                                          final feed = feeds.first;
                                          bool postLiked =
                                              feed.likes.contains(myID);

                                          return Padding(
                                            padding: EdgeInsets.only(
                                                right: 15,
                                                bottom: post.photoUrl.isEmpty
                                                    ? 5
                                                    : 10,
                                                top: post.photoUrl.isEmpty
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
                                                          (bool isLiked) {
                                                        return Icon(
                                                          postLiked
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: postLiked
                                                              ? Colors
                                                                  .pinkAccent
                                                              : Colors.grey
                                                                  .shade800,
                                                          size: 19,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 6.0),
                                                    AnimatedSwitcher(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      transitionBuilder:
                                                          (child, animation) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                      child: Text(
                                                        feed.likes.length
                                                            .toString(),
                                                        key: ValueKey<int>(
                                                            feed.likes.length),
                                                        style: const TextStyle(
                                                            fontSize: 12.0,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.chat_bubble_outline,
                                                      color: feed.isCommentsOpen
                                                          ? Colors.grey.shade700
                                                          : Colors.grey.shade800
                                                              .withOpacity(0.6),
                                                      size: 18.0,
                                                    ),
                                                    const SizedBox(width: 6.0),
                                                    Text(
                                                      feed.commentCount
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      LineIcons.share,
                                                      color:
                                                          Colors.grey.shade700,
                                                      size: 18.0,
                                                    ),
                                                    const SizedBox(width: 6.0),
                                                    const Text(
                                                      '0',
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .stacked_bar_chart_rounded,
                                                      color:
                                                          Colors.grey.shade700,
                                                      size: 18.0,
                                                    ),
                                                    const SizedBox(width: 6.0),
                                                    Text(
                                                      feed.views.length
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        error: (error, trace) => ErrorText(
                                          error: error.toString(),
                                        ),
                                        loading: () => Padding(
                                          padding: EdgeInsets.only(
                                              right: 15,
                                              bottom: post.photoUrl.isEmpty
                                                  ? 5
                                                  : 10,
                                              top: post.photoUrl.isEmpty
                                                  ? 10
                                                  : 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  LikeButton(
                                                    size: 19,
                                                    onTap: (isLiked) =>
                                                        onLikeButtonTapped(
                                                            isLiked,
                                                            post.feedID),
                                                    likeBuilder:
                                                        (bool isLiked) {
                                                      return Icon(
                                                        feedLiked
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color: feedLiked
                                                            ? Colors.pinkAccent
                                                            : Colors
                                                                .grey.shade800,
                                                        size: 19,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    transitionBuilder:
                                                        (child, animation) {
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      );
                                                    },
                                                    child: Text(
                                                      post.likes.length
                                                          .toString(),
                                                      key: ValueKey<int>(
                                                          post.likes.length),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.chat_bubble_outline,
                                                    color: post.isCommentsOpen
                                                        ? Colors.grey.shade700
                                                        : Colors.grey.shade800
                                                            .withOpacity(0.6),
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  Text(
                                                      post.commentCount
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    LineIcons.share,
                                                    color: Colors.grey.shade700,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  const Text(
                                                    '0',
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .stacked_bar_chart_rounded,
                                                    color: Colors.grey.shade700,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  Text(
                                                      post.views.length
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey)),
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
              error: (error, trace) => ErrorText(error: error.toString()),
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
            );
      },
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

class ImageSlidePage extends ConsumerWidget {
  final String imageUrl;

  ImageSlidePage({required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decoded = Uri.decodeComponent(imageUrl);
    void download() {
      ref
          .watch(userProfileControllerProvider.notifier)
          .downloadImage(decoded, context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
        title: const Text('Image Slide Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OutlinedButton(
              onPressed: download,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.2, 30),
                side: const BorderSide(
                  color: Colors.blue,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Hero(
          tag: decoded,
          child: ExtendedImageSlidePage(
            slideAxis: SlideAxis.both,
            slideType: SlideType.onlyImage,
            child: ExtendedImage.network(
              enableSlideOutPage: true,
              decoded,
              borderRadius: BorderRadius.circular(0),
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
            ),
          ),
        ),
      ),
    );
  }
}
