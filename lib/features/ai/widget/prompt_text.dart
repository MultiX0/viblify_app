import 'package:flutter/material.dart';

import '../../../theme/pallete.dart';
import '../models/image_generate_ai_model.dart';

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
