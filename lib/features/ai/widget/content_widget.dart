import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../enums/request_type.dart';
import '../models/image_generate_ai_model.dart';
import 'bot_body.dart';
import 'bot_header.dart';
import 'prompt_text.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({
    super.key,
    required ScrollController scrollController,
    required this.prompts,
    required this.size,
    required this.isLoading,
    required this.request_type,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final Size size;
  final bool isLoading;
  final List<ImageGenerateAiModel> prompts;
  final AiRequestType request_type;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: prompts.isNotEmpty
          ? ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                final createdAt = timeago.format(prompt.createdAt, locale: 'en_short');
                final response_date = timeago.format(prompt.response_date, locale: 'en_short');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PromptText(size: size, prompt: prompt, createdAt: createdAt),
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
    );
  }
}
