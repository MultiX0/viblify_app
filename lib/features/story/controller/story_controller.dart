// ignore_for_file: camel_case_types

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/story/models/story_model.dart';
import 'package:viblify_app/features/story/repository/story_repository.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';

final getAllStoriesProvider = StreamProvider((ref) {
  final myData = ref.read(userProvider)!;
  final storyController = ref.watch(storyControllerProvider.notifier);
  return storyController.getAllStories(myData.userID, myData.following);
});

final getAllUserStoriesProvider = StreamProvider.family((ref, String userID) {
  final storyController = ref.watch(storyControllerProvider.notifier);
  return storyController.getAllUserStories(userID);
});

final storyControllerProvider = StateNotifierProvider<Story_Controller, bool>((ref) {
  final _repository = ref.watch(storyRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return Story_Controller(repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class Story_Controller extends StateNotifier<bool> {
  final uuid = const Uuid();
  StoryRepository _repository;
  StorageRepository _storageRepository;
  final Ref _ref;
  Story_Controller(
      {required StoryRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  Future<void> postStory({
    required File image,
    required BuildContext context,
  }) async {
    try {
      state = true;
      var story_id = uuid.v4();
      final uid = _ref.read(userProvider)!.userID;

      Story story = Story(
        content_url: "",
        userID: uid,
        views: const [],
        storyID: story_id,
        createdAt: DateTime.now(),
      );

      final res = await _storageRepository.storeFile(
        path: 'stories/$uid',
        id: story_id,
        file: image,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => story = story.copyWith(content_url: r),
      );

      final result = await _repository.postStory(story);

      state = false;
      result.fold((l) => showSnackBar(context, l.message), (r) async {
        showSnackBar(context, "Story Created Successfully");
        context.pop();
      });
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }

  Stream<List<Story>> getAllStories(String _userID, List<dynamic> myFollowing) {
    return _repository.getAllStories(_userID, myFollowing);
  }

  Future<void> viewStory({required String storyID, required String userID}) async {
    _repository.viewStory(storyID, userID);
  }

  Stream<List<Story>> getAllUserStories(String userID) {
    return _repository.getUserStories(userID);
  }
}
