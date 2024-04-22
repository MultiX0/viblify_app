// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/ai/controller/ai_controller.dart';
import 'package:viblify_app/features/ai/models/image_generate_ai_model.dart';
import 'package:viblify_app/theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';
import '../enums/image_ai_style.dart';
import '../enums/request_type.dart';
import '../widget/content_widget.dart';

class ViblifyAi extends ConsumerStatefulWidget {
  const ViblifyAi({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageGenerateAiState();
}

class _ImageGenerateAiState extends ConsumerState<ViblifyAi> {
  AiImageStyle currentStyle = AiImageStyle.anime;
  AiRequestType request_type = AiRequestType.text_ai;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  String text = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(aiControllerProvider);
    final myData = ref.watch(userProvider)!;
    void addPrompt(int toDay_prompts) {
      var uuid = const Uuid();
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
      if (_textController.text.trim().length >= 4 || request_type != AiRequestType.image_ai) {
        log(myData.userID);
        log("is user mod ? : ${myData.isUserMod}");
        if (myData.isUserMod == true) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(
                  body: text.trim(),
                  request_type: request_type,
                  aiModel: aiModel,
                  imageAIStyle: convertToImageAIStyle(currentStyle))
              .then((e) => _scrollController.jumpTo(0));
        } else if (aiModel.request_type == AiRequestType.text_ai) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(
                  body: text.trim(),
                  request_type: request_type,
                  aiModel: aiModel,
                  imageAIStyle: convertToImageAIStyle(currentStyle))
              .then((e) => _scrollController.jumpTo(0));
        } else if (toDay_prompts < 3) {
          _textController.clear();
          ref
              .read(aiControllerProvider.notifier)
              .addPrompt(
                  body: text.trim(),
                  request_type: request_type,
                  aiModel: aiModel,
                  imageAIStyle: convertToImageAIStyle(currentStyle))
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
                        ContentWidget(
                            scrollController: _scrollController,
                            size: size,
                            isLoading: isLoading,
                            prompts: prompts,
                            request_type: request_type),
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
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: request_type != AiRequestType.text_ai
                                          ? "Write what you want to draw..."
                                          : "Write what you want to ask...",
                                      hintStyle: const TextStyle(fontSize: 12),
                                    ),
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
                                if (!isLoading) ...[
                                  if (request_type == AiRequestType.image_ai)
                                    IconButton(
                                      tooltip: "image type",
                                      onPressed: () => showStylePicker(
                                        context: context,
                                        currentStyle: currentStyle,
                                        onStyleSelected: (value) => setState(() {
                                          currentStyle = value;
                                        }),
                                      ),
                                      icon: Icon(
                                        Ionicons.images,
                                        color: Colors.pink[700],
                                      ),
                                    ),
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
                                  ),
                                ] else
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
