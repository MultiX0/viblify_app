import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/ai/controller/ai_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viblify_app/theme/pallete.dart';

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
    // final myData = ref.watch(userProvider)!;
    void addPrompt() {
      ref
          .read(aiControllerProvider.notifier)
          .addPrompt(body: text.trim())
          .then((e) => _scrollController.jumpTo(0));
      _textController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("viblify ai"),
        centerTitle: true,
      ),
      body: ref.watch(getUserPromptsProvider).when(
            data: (prompts) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: prompts.length,
                      itemBuilder: (context, index) {
                        final prompt = prompts[index];

                        final createdAt = timeago.format(prompt.createdAt, locale: 'en_short');
                        final response_date =
                            timeago.format(prompt.response_date, locale: 'en_short');
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[900],
                                            backgroundImage:
                                                const AssetImage("assets/images/ai.jpg"),
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
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                                                  style: TextStyle(
                                                      fontSize: 11, color: Colors.grey[700]),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 15),
                                              margin: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(
                                                color: DenscordColors.scaffoldForeground,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child:
                                                  const Text("generating the image please wait..."),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: DenscordColors.scaffoldForeground,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(prompt.body),
                                ),
                                Text(
                                  createdAt,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
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
                            onPressed: isLoading ? null : addPrompt,
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
            loading: () => const Loader(),
          ),
    );
  }
}
