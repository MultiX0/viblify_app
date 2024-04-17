// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/story/controller/story_controller.dart';

import '../../../core/utils.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  String? path;

  void imagePicker() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        path = result.files.first.path!;
      });
    } else {
      context.pop();
    }
  }

  bool isLoading = false;

  @override
  void initState() {
    imagePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(storyControllerProvider);
    void addStory() {
      ref.watch(storyControllerProvider.notifier).postStory(image: File(path!), context: context);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: addStory,
        child: isLoading
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.done),
      ),
      body: Center(
        child: path != null
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
              )
            : const Loader(),
      ),
    );
  }
}
