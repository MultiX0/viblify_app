import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/ai/controller/ai_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/features/ai/models/image_generate_ai_model.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../../auth/controller/auth_controller.dart';

class ImageGenerateAi extends ConsumerStatefulWidget {
  const ImageGenerateAi({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageGenerateAiState();
}

class _ImageGenerateAiState extends ConsumerState<ImageGenerateAi> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  String text = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(aiControllerProvider);
    final myData = ref.watch(userProvider)!;
    void addPrompt(int toDay_prompts) {
      if (text.length >= 4) {
        log(myData.userID);
        log("is user mod ? : ${myData.isUserMod}");
        if (myData.isUserMod == true) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(body: text.trim())
              .then((e) => _scrollController.jumpTo(0));
        } else if (toDay_prompts < 3) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(body: text.trim())
              .then((e) => _scrollController.jumpTo(0));
        } else {
          _textController.clear();
          showSnackBar(context, "You can generate only 3 images per day.");
        }
      } else {
        showSnackBar(context, "You must enter at least 4 fields");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("viblify ai"),
        centerTitle: true,
      ),
      body: ref.watch(getUserPromptsProvider).when(
            data: (prompts) {
              return ref.watch(getUserPromptCountProvider).when(
                  data: (promptsCount) {
                    return Column(
                      children: [
                        Expanded(
                          child: prompts.isNotEmpty
                              ? ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  itemCount: prompts.length,
                                  itemBuilder: (context, index) {
                                    final prompt = prompts[index];
                                    final createdAt =
                                        timeago.format(prompt.createdAt, locale: 'en_short');
                                    final response_date =
                                        timeago.format(prompt.response_date, locale: 'en_short');

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        PromptText(
                                            size: size, prompt: prompt, createdAt: createdAt),
                                        BotHeader(
                                          prompt: prompt,
                                          size: size,
                                          response_date: response_date,
                                          isLoading: isLoading,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const BotBody(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: DenscordColors.scaffoldForeground,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Write what you want to draw...",
                                        hintStyle: TextStyle(fontSize: 12)),
                                    controller: _textController,
                                    onChanged: (val) {
                                      setState(() {
                                        text = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (isLoading) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                IconButton(
                                  onPressed: isLoading ? null : () => addPrompt(promptsCount),
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        )
                      ],
                    );
                  },
                  error: (error, trace) => ErrorText(error: error.toString()),
                  loading: () => const Loader());
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

class BotBody extends StatelessWidget {
  const BotBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "No Data Yet..",
            style: TextStyle(fontFamily: "FixelDisplay", color: Colors.grey[200], fontSize: 32),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            "Engage your imagination",
            style: TextStyle(
              fontFamily: "FixelText",
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class BotHeader extends StatelessWidget {
  const BotHeader({
    super.key,
    required this.prompt,
    required this.size,
    required this.response_date,
    required this.isLoading,
  });

  final ImageGenerateAiModel prompt;
  final bool isLoading;
  final Size size;
  final String response_date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[900],
                backgroundImage: const AssetImage("assets/images/ai.jpg"),
                radius: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                "viblify.ai",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: prompt.img_url.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Hero(
                      tag: prompt.img_url,
                      child: GestureDetector(
                        onTap: () => context.push(
                          "/img/slide/${base64UrlEncode(utf8.encode(prompt.img_url))}",
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            width: size.width * 0.5,
                            height: size.width * 0.5,
                            image: CachedNetworkImageProvider(
                              prompt.img_url,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      response_date,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: DenscordColors.scaffoldForeground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: (prompt.hasError)
                      ? const Text(
                          "I'm very sorry. It seems like an error occurred. Please try again")
                      : const Text("generating the image please wait..."),
                ),
        ),
      ],
    );
  }
}

class PromptText extends StatelessWidget {
  const PromptText({
    super.key,
    required this.size,
    required this.prompt,
    required this.createdAt,
  });

  final Size size;
  final ImageGenerateAiModel prompt;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: size.width * 0.75),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: DenscordColors.scaffoldForeground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(prompt.body),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            createdAt,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
