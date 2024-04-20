import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/ai/controller/ai_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/features/ai/models/image_generate_ai_model.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../../auth/controller/auth_controller.dart';
import '../enums/request_type.dart';

class ViblifyAi extends ConsumerStatefulWidget {
  const ViblifyAi({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageGenerateAiState();
}

class _ImageGenerateAiState extends ConsumerState<ViblifyAi> {
  AiRequestType request_type = AiRequestType.image_ai;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  String text = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(aiControllerProvider);
    final myData = ref.watch(userProvider)!;
    void addPrompt(int toDay_prompts) {
      var uuid = Uuid();
      ImageGenerateAiModel aiModel = ImageGenerateAiModel(
        prompt_id: uuid.v4(),
        response: '',
        userID: myData.userID,
        request_type: request_type,
        hasError: false,
        img_url: "",
        createdAt: DateTime.now(),
        response_date: DateTime.now(),
        body: text,
      );
      if (_textController.text.trim().length >= 4) {
        log(myData.userID);
        log("is user mod ? : ${myData.isUserMod}");
        if (myData.isUserMod == true) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(body: text.trim(), request_type: request_type, aiModel: aiModel)
              .then((e) => _scrollController.jumpTo(0));
        } else if (aiModel.request_type == AiRequestType.text_ai) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(body: text.trim(), request_type: request_type, aiModel: aiModel)
              .then((e) => _scrollController.jumpTo(0));
        } else if (toDay_prompts < 3) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(body: text.trim(), request_type: request_type, aiModel: aiModel)
              .then((e) => _scrollController.jumpTo(0));
        } else {
          _textController.clear();
          showSnackBar(context, "You can generate only 3 images per day.");
        }
      } else {
        showSnackBar(context, "You must enter at least 4 fields");
      }
    }

    void requestTypeAction() {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: Icon(Icons.image,
                    color:
                        request_type == AiRequestType.image_ai ? Colors.blue[900]! : Colors.white),
                title: Text(
                  'AI Image Generator',
                  style: TextStyle(
                      color: request_type == AiRequestType.image_ai
                          ? Colors.blue[900]!
                          : Colors.white),
                ),
                onTap: () {
                  setState(() {
                    request_type = AiRequestType.image_ai;
                  });
                  log(getRequestType(request_type));
                  context.pop();
                }),
            ListTile(
                leading: Icon(Icons.text_format,
                    color:
                        request_type == AiRequestType.text_ai ? Colors.blue[900]! : Colors.white),
                title: Text(
                  'AI Text Generator',
                  style: TextStyle(
                      color:
                          request_type == AiRequestType.text_ai ? Colors.blue[900]! : Colors.white),
                ),
                onTap: () {
                  setState(() {
                    request_type = AiRequestType.text_ai;
                  });
                  log(getRequestType(request_type));
                  context.pop();
                }),
          ],
        ),
      );
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
                                          request_type: request_type,
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
                                if (!isLoading)
                                  IconButton(
                                    onPressed: requestTypeAction,
                                    icon: Icon(
                                      request_type == AiRequestType.image_ai
                                          ? Icons.image
                                          : Icons.text_format,
                                      color: request_type == AiRequestType.image_ai
                                          ? Colors.pink[700]
                                          : Colors.green[300],
                                    ),
                                  )
                                else
                                  const SizedBox(),
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
    Key? key,
    required this.prompt,
    required this.size,
    required this.response_date,
    required this.request_type,
    required this.isLoading,
  }) : super(key: key);

  final ImageGenerateAiModel prompt;
  final bool isLoading;
  final Size size;
  final AiRequestType request_type;
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
                width: 8,
              ),
              const Text(
                "viblify.ai",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (prompt.request_type == AiRequestType.image_ai) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: prompt.response.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: size.width * 0.75),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: DenscordColors.scaffoldForeground,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          child: parseText(prompt.response),
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
                        : const Text("The answer is being written"),
                  ),
          ),
        ],
      ],
    );
  }

  Widget parseText(String text) {
    List<Widget> widgets = [];

    // Find and replace the text between ** with bold and larger text
    RegExp boldRegex =
        RegExp(r'\*\*(\S(?:.*?\S)?)\*\*'); // Match non-whitespace characters surrounded by **
    text.splitMapJoin(
      boldRegex,
      onMatch: (Match match) {
        String boldText =
            match.group(1)!; // Extract matched group without leading/trailing whitespace
        widgets.add(
          Text(
            boldText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        widgets.add(Text(
          nonMatch.replaceAll('*', '').replaceAll('\n\n', '\n'),
          style: TextStyle(color: Colors.grey[300]),
        ));
        return '';
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
