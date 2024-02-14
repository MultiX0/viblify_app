// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/features/giphy/api_key.dart';
import 'dart:ui' as ui;

import '../../../core/utils.dart';
import '../../../widgets/empty_widget.dart';
import '../../../widgets/feeds_widget.dart';
import '../controller/comment_controller.dart';

TextEditingController commentController = TextEditingController();

class CommentsCard extends ConsumerStatefulWidget {
  final String feedID;
  final String feedUserID;
  const CommentsCard(
      {super.key, required this.feedID, required this.feedUserID});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentsCard> {
  //Gif
  GiphyGif? currentGif;

  // Giphy Client
  late GiphyClient client = GiphyClient(apiKey: apiKey, randomId: '');

  // Random ID
  String randomId = "";

  String giphyApiKey = apiKey;

  void selectPostImage() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        img = File(result.files.first.path!);
        currentGif = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      client.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });
  }

  File? img;
  List<String> tags = [];
  var lastContent = "";

  bool showMore = false;
  final FocusNode _focusNode = FocusNode();
  static final GlobalKey<FormFieldState<String>> _searchFormKey =
      GlobalKey<FormFieldState<String>>();
  String previousText = '';
  bool arabic = true;

  void _onTextChanged() {
    final currentText = commentController.text;

    if (currentText.length >= previousText.length) {
      setState(() {
        showMore = true;
      });
    }

    previousText = currentText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myData = ref.watch(userProvider)!;

    void deleteComment(String commentID) {
      showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("هل تريد حذف التعليق؟"),
            content: const Text(
                "هل أنت متأكد من رغبتك في حذف هذا التعليق , مع العلم أن قرار الحذف نهائي ولا يتم الرجوع فيه"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("رجوع"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .watch(commentsControllerProvider.notifier)
                      .deleteComment(commentID, widget.feedID);
                },
                child: const Text("تأكيد"),
              ),
            ],
          );
        }),
      );
    }

    void more(
      String commentID,
      String commentUserID,
    ) {
      showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: false,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((myData.userID == commentUserID) ||
                    (myData.userID == widget.feedUserID)) ...[
                  ListTile(
                    title: const Text("Delete"),
                    leading: const Icon(Icons.delete),
                    onTap: () {
                      Navigator.of(context).pop();
                      deleteComment(commentID);
                    },
                  ),
                ]
              ],
            );
          });
    }

    void saveComment() {
      if (commentController.text.trim().length >= 4) {
        ref.watch(commentsControllerProvider.notifier).addComment(
              image: img,
              content: commentController.text.trim(),
              feedID: widget.feedID,
              context: context,
              gif: currentGif?.images!.fixedHeight!.url ?? "",
              tags: tags,
            );
        setState(() {
          img = null;
          currentGif = null;
        });
        commentController.clear();
      } else if (commentController.text.trim().length < 4 &&
          commentController.text.isNotEmpty) {
        Fluttertoast.showToast(msg: "الرجاء ادخال 4 أحرف كحد أدنى");
      } else if (commentController.text.isEmpty) {
        Fluttertoast.showToast(msg: "الرجاء ادخال 4 أحرف كحد أدنى");
      }
    }

    void likeHunlidng(String feedID, String commentID) {
      ref
          .watch(commentsControllerProvider.notifier)
          .likeHundling(feedID, commentID, myData.userID);
    }

    Future<bool> onLikeButtonTapped(
        bool isLiked, String feedID, String commentID) async {
      likeHunlidng(feedID, commentID);
      return !isLiked;
    }

    return GiphyGetWrapper(
      giphy_api_key: giphyApiKey,
      builder: (stream, giphyGetWrapper) {
        stream.listen((gif) {
          setState(() {
            currentGif = gif;
          });
        });

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: WillPopScope(
            onWillPop: () async {
              FocusScope.of(context).unfocus();
              setState(() {
                img = null;
              });
              commentController.clear();
              return true; // Return true to allow the back navigation
            },
            child: ref.watch(getAllCommentsProvider(widget.feedID)).when(
                  data: (comments) {
                    bool hasAnyShowed =
                        comments.any((comment) => comment.isShowed);

                    return Column(
                      children: [
                        Expanded(
                          child: (comments.isNotEmpty && hasAnyShowed)
                              ? ListView.builder(
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = comments[index];
                                    bool isArabic =
                                        Bidi.hasAnyRtl(comment.content);
                                    bool commentLiked =
                                        comment.likes.contains(myData.userID);

                                    String paresedImg =
                                        Uri.encodeComponent(comment.photoUrl);
                                    final feedTime = timeago.format(
                                        comment.createdAt.toDate(),
                                        locale: 'en_short');
                                    return comment.isShowed != false
                                        ? ref
                                            .watch(getUserDataProvider(
                                                comment.userID))
                                            .when(
                                              data: (user) {
                                                return ListTile(
                                                  titleAlignment:
                                                      ListTileTitleAlignment
                                                          .top,
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            user.profilePic),
                                                  ),
                                                  title: Row(
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
                                                                        myData
                                                                            .userID
                                                                    ? null
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
                                                                  onTap: () =>
                                                                      user.userID !=
                                                                              myData.userID
                                                                          ? null
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
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            15),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () => more(
                                                                      comment
                                                                          .commentID,
                                                                      comment
                                                                          .userID),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .more_horiz,
                                                                    size: 14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: 10,
                                                            bottom: 5,
                                                            right: 5),
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 7,
                                                                horizontal: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey[900]!
                                                              .withOpacity(0.9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Text(
                                                          comment.content,
                                                          textDirection: isArabic
                                                              ? ui.TextDirection
                                                                  .rtl
                                                              : ui.TextDirection
                                                                  .ltr,
                                                        ),
                                                      ),
                                                      if (comment
                                                          .gif.isNotEmpty) ...[
                                                        Padding(
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
                                                              comment.gif,
                                                              loadStateChanged:
                                                                  (ExtendedImageState
                                                                      state) {
                                                                switch (state
                                                                    .extendedImageLoadState) {
                                                                  case LoadState
                                                                        .loading:
                                                                    return AspectRatio(
                                                                      aspectRatio:
                                                                          16 /
                                                                              9,
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
                                                                            color:
                                                                                Colors.grey.shade900,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );

                                                                  case LoadState
                                                                        .completed:
                                                                    return ExtendedRawImage(
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
                                                      ],
                                                      if (comment.photoUrl
                                                          .isNotEmpty) ...[
                                                        Hero(
                                                          tag: comment.photoUrl,
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
                                                              child:
                                                                  ExtendedImage
                                                                      .network(
                                                                comment
                                                                    .photoUrl,
                                                                loadStateChanged:
                                                                    (ExtendedImageState
                                                                        state) {
                                                                  switch (state
                                                                      .extendedImageLoadState) {
                                                                    case LoadState
                                                                          .loading:
                                                                      return AspectRatio(
                                                                        aspectRatio:
                                                                            16 /
                                                                                9,
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
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: Colors.grey.shade900,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );

                                                                    case LoadState
                                                                          .completed:
                                                                      return GestureDetector(
                                                                        onTap: () =>
                                                                            Navigator.of(context).push(
                                                                          MaterialPageRoute(
                                                                            builder: ((context) =>
                                                                                ImageSlidePage(imageUrl: paresedImg)),
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
                                                          .watch(getCommentsByCommentIDAndFeedID(
                                                              Tuple2(
                                                                  comment
                                                                      .commentID,
                                                                  widget
                                                                      .feedID)))
                                                          .when(
                                                            data: (feeds) {
                                                              final feed =
                                                                  feeds.first;
                                                              bool postLiked = feed
                                                                  .likes
                                                                  .contains(myData
                                                                      .userID);

                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            15,
                                                                        top: 5,
                                                                        left:
                                                                            15),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        LikeButton(
                                                                          size:
                                                                              19,
                                                                          onTap: (isLiked) => onLikeButtonTapped(
                                                                              isLiked,
                                                                              widget.feedID,
                                                                              comment.commentID),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              postLiked ? Icons.favorite : Icons.favorite_border,
                                                                              color: postLiked ? Colors.pinkAccent : Colors.grey.shade800,
                                                                              size: 19,
                                                                            );
                                                                          },
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                6.0),
                                                                        AnimatedSwitcher(
                                                                          duration:
                                                                              const Duration(milliseconds: 300),
                                                                          transitionBuilder:
                                                                              (child, animation) {
                                                                            return FadeTransition(
                                                                              opacity: animation,
                                                                              child: child,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            feed.likes.length.toString(),
                                                                            key:
                                                                                ValueKey<int>(feed.likes.length),
                                                                            style:
                                                                                const TextStyle(fontSize: 12.0, color: Colors.grey),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .chat_bubble_outline,
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
                                                                          feed.replies
                                                                              .length
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
                                                                              fontSize: 12.0,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            error: (error,
                                                                    trace) =>
                                                                ErrorText(
                                                              error: error
                                                                  .toString(),
                                                            ),
                                                            loading: () =>
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 15,
                                                                      top: 5,
                                                                      left: 15),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      LikeButton(
                                                                        size:
                                                                            19,
                                                                        onTap: (isLiked) => onLikeButtonTapped(
                                                                            isLiked,
                                                                            widget.feedID,
                                                                            comment.commentID),
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            commentLiked
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: commentLiked
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
                                                                        duration:
                                                                            const Duration(milliseconds: 300),
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
                                                                          comment
                                                                              .likes
                                                                              .length
                                                                              .toString(),
                                                                          key: ValueKey<int>(comment
                                                                              .likes
                                                                              .length),
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
                                                                        Icons
                                                                            .chat_bubble_outline,
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
                                                                          comment
                                                                              .replies
                                                                              .length
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 12.0,
                                                                              color: Colors.grey)),
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
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                    ],
                                                  ),
                                                );
                                              },
                                              error: (error, trace) =>
                                                  ErrorText(
                                                error: error.toString(),
                                              ),
                                              loading: () => const Loader(),
                                            )
                                        : const SizedBox();
                                  },
                                )
                              : const MyEmptyShowen(text: "لاتوجد اي تعليقات"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (currentGif != null) ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: ExtendedImage.network(
                                                currentGif!
                                                    .images!.fixedWidth.url,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                fit: BoxFit.cover,
                                                cache: true,
                                              ),
                                            ),
                                            Positioned(
                                              top: 17.5,
                                              left: -12,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    currentGif = null;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (img != null) ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Image.file(
                                                img!,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 17.5,
                                              left: -12,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    img = null;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(myData.profilePic),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20)),
                                    color: Colors.grey[900],
                                  ),
                                  child: TextFormField(
                                    scrollPhysics:
                                        const NeverScrollableScrollPhysics(),
                                    cursorColor: const Color(0xFF0D47A1),
                                    cursorHeight: 25,
                                    focusNode: _focusNode,
                                    onChanged: (val) {
                                      setState(() {
                                        showMore = false;
                                        arabic = Bidi.hasAnyRtl(val);
                                      });
                                    },
                                    controller: commentController,
                                    key: _searchFormKey,
                                    textDirection: arabic
                                        ? ui.TextDirection.rtl
                                        : ui.TextDirection.ltr,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        height: 1.5,
                                        fontSize: 13),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      alignLabelWithHint: true,
                                      hintTextDirection: ui.TextDirection.rtl,
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade700,
                                          height: 1.6,
                                          fontSize: 13),
                                      hintText: "كتابة تعليق",
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                  color: Colors.grey[900],
                                ),
                                child: IconButton(
                                  splashRadius: 1,
                                  padding: EdgeInsets.zero,
                                  onPressed: saveComment,
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                              if (!_focusNode.hasFocus || showMore == true) ...[
                                IconButton(
                                  onPressed: selectPostImage,
                                  icon: Icon(
                                    Icons.photo,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    giphyGetWrapper.getGif(
                                      '',
                                      context,
                                      showGIFs: true,
                                      showStickers: true,
                                      showEmojis: true,
                                    );
                                    if (img != null) {
                                      setState(() {
                                        img = null;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.gif_box_outlined,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.emoji_emotions,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ] else ...[
                                IconButton(
                                  onPressed: _onTextChanged,
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  error: (error, trace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                ),
          ),
        );
      },
    );
  }

  void getTagsMethod() {
    int countChar(String str, String x, int n) {
      int count = 0;

      for (int i = 0; i < str.length; i++) {
        if (str[i] == x) {
          count++;
        }
      }

      // At least k repetitions are required
      double repetitions = n / str.length;
      count = (count * repetitions).toInt();

      // If n is not the multiple of the string size, check for the remaining repeating character.
      for (int i = 0; i < n % str.length; i++) {
        if (str[i] == x) {
          count++;
        }
      }

      return count;
    }

    void getTags(String text) {
      for (int i = 0; i < text.length; i++) {
        var charIn = text.indexOf('#');

        if (charIn == -1) {
          // No more '#' found in the string
          break;
        }

        var newContent = text.substring(charIn + 1);
        var endContent = newContent.indexOf(' ');

        var newText = endContent == -1
            ? newContent.trim() // if '#' is at the end of the string
            : newContent.substring(0, endContent).trim();

        text = text.replaceFirst('#$newText', "");
        lastContent = text;

        print("Original text: $text");
        print("Extracted hashtag: #$newText");
        // Assuming 'tags' is a List<String> defined elsewhere in your code
        tags.add(newText);
      }
    }

    String text = commentController.text;
    var count = countChar(text, '#', text.length);
    if (count > 0) {
      getTags(text);
    } else {
      lastContent = text;
    }
  }
}
