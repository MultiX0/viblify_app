import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:viblify_app/core/methods/youtube_video_validator.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/features/user_profile/screens/video_screen.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'dart:ui' as ui;
import '../../giphy/api_key.dart';

TextEditingController videoController = TextEditingController();

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  //Gif
  GiphyGif? currentGif;

  // Giphy Client
  late GiphyClient client = GiphyClient(apiKey: apiKey, randomId: '');

  // Random ID
  String randomId = "";
  String videoLink = "";
  String videoID = "";
  String videoTitle = "";

  String giphyApiKey = apiKey;

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

  bool isCommentsOpen = true;
  void selectPostImage() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        img = File(result.files.first.path!);
        currentGif = null;
      });
    }
  }

  void commentsOpen() {
    if (isCommentsOpen == true) {
      setState(() {
        isCommentsOpen = false;
      });
    } else {
      setState(() {
        isCommentsOpen = true;
      });
    }
  }

  ScrollController _scrollController = ScrollController();

  void addYouTubeUrl() {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: _scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const Text('اضف رابط يوتيوب'),
                    IconButton(
                      onPressed: () async {
                        if (VideoURLValidator.isYouTubeLink(
                            videoController.text)) {
                          if (await VideoURLValidator
                              .checkVideoIsAvailableOnYoutube(
                                  videoController.text)) {
                            Fluttertoast.showToast(msg: "the link is valid");
                            Navigator.pop(context);

                            setState(() async {
                              videoID = VideoURLValidator.extractYouTubeVideoId(
                                  videoController.text);

                              videoTitle =
                                  (await VideoURLValidator.getVideoTitle(
                                      videoID))!;
                              videoController.clear();
                            });
                            print(videoController.text);
                            print(videoID);
                          } else {
                            Fluttertoast.showToast(
                                msg: "الفيديو الذي قمت بادخاله غير موجود");
                          }
                        } else {
                          Fluttertoast.showToast(msg: "الرجاء ادحال رابط صحيح");
                        }
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
                TextField(
                  controller: videoController,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {
                      videoLink = val;
                    });
                  },
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  onTap: () {
                    Timer(const Duration(milliseconds: 200), () {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "https://youtu.be/xxxxxxxx",
                    hintStyle: TextStyle(
                      color: Colors.grey[600]!,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue[800]!, width: 1.5),
                    ),
                    enabled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[900]!),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  List<String> tags = [];
  var lastContent = "";

  File? img;
  final postController = TextEditingController();
  String postContent = "";
  void addPost() {
    getTagsMethod();
    ref.watch(postControllerProvider.notifier).addPost(
        image: img,
        content: lastContent,
        videoID: videoID,
        isCommentsOpen: isCommentsOpen,
        context: context,
        tags: tags,
        gif: currentGif?.images!.fixedWidth.url ?? "");

    setState(() {
      img = null;
      currentGif = null;
    });
  }

  Future<void> deleteFile() async {
    setState(() {
      img = null;
    });
  }

  Future<void> removeVideo() async {
    setState(() {
      videoID = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);
    final user = ref.read(userProvider)!;
    bool isArabic = Bidi.hasAnyRtl(postController.text);

    return GiphyGetWrapper(
      giphy_api_key: giphyApiKey,
      builder: (stream, giphyGetWrapper) {
        stream.listen((gif) {
          setState(() {
            currentGif = gif;
          });
        });

        return Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("Viblify"),
            actions: [
              if (postContent.trim().length > 8) ...[
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  TextButton(
                    onPressed: addPost,
                    child: Text(
                      "Post",
                      style: TextStyle(color: Colors.blue[800]!),
                    ),
                  ),
              ]
            ],
          ),
          backgroundColor: Pallete.blackColor,
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                user.profilePic,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  user.userName,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: postController,
                          onChanged: (val) {
                            setState(() {
                              postContent = val;
                            });
                          },
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          maxLength: 2200,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Pallete.blackColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Pallete.blackColor),
                            ),
                            hintText: 'بماذا تفكر؟',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintTextDirection: ui.TextDirection.rtl,
                          ),
                          textDirection: isArabic
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (img != null) ...[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      img!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    child: IconButton(
                                      onPressed: deleteFile,
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (currentGif != null) ...[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      currentGif!.images!.fixedWidth.url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    child: IconButton(
                                      onPressed: deleteFile,
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (videoID.isNotEmpty) ...[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      VideoURLValidator.getYouTubeThumbnail(
                                          videoID),
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    child: IconButton(
                                      onPressed: removeVideo,
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onTap: navigationToVideScreen,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2.5),
                                        ),
                                        child: const Icon(
                                          Icons.play_circle,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade800))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip:
                                img == null ? "add image" : "remove the image",
                            onPressed: videoID.isEmpty ? selectPostImage : null,
                            icon: const Icon(LineIcons.image),
                          ),
                          IconButton(
                            tooltip: "add gif",
                            onPressed: videoID.isEmpty
                                ? () async {
                                    giphyGetWrapper.getGif(
                                      '',
                                      context,
                                      showGIFs: true,
                                      showStickers: false,
                                      showEmojis: false,
                                    );
                                    if (img != null) {
                                      setState(() {
                                        img = null;
                                      });
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.gif_box_outlined),
                          ),
                          IconButton(
                            tooltip: "add youtube video",
                            onPressed: addYouTubeUrl,
                            icon: const Icon(
                              LineIcons.youtube,
                            ),
                          ),
                          IconButton(
                            onPressed: commentsOpen,
                            tooltip: isCommentsOpen
                                ? "disable Comments"
                                : "enable the comments",
                            icon: isCommentsOpen
                                ? const Icon(LineIcons.commentSlash)
                                : const Icon(LineIcons.comment),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void navigationToVideScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoScreen(id: videoID, nameOfVideo: videoTitle),
      ),
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

    String text = postContent;
    var count = countChar(text, '#', text.length);
    if (count > 0) {
      getTags(text);
    } else {
      lastContent = text;
    }
  }
}
