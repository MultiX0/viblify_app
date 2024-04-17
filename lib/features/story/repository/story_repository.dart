// ignore_for_file: void_checks, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/story/models/story_model.dart';

import '../../../../core/Constant/firebase_constant.dart';
import '../../../../core/type_defs.dart';

final storyRepositoryProvider = Provider((ref) {
  return StoryRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class StoryRepository {
  final supabase = Supabase.instance.client;
  StoryRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _stories => supabase.from(FirebaseConstant.storiesCollection);
  FutureVoid postStory(Story story) async {
    try {
      return right(await _stories.insert(story.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Story>> getAllStories(WidgetRef ref) {
    final myData = ref.watch(userProvider)!;
    final myFollowing = ref.watch(userProvider)!.following;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return _stories
        .stream(primaryKey: ['storyID'])
        .gt("createdAt", yesterday.millisecondsSinceEpoch)
        .order("createdAt", ascending: false)
        .map((data) {
          Map<String, Story> userStoriesMap = {}; // Map to store stories for each user
          for (var story in data) {
            final currentStory = Story.fromMap(story);
            if (myFollowing.contains(currentStory.userID) || currentStory.userID == myData.userID) {
              // Check if the user already exists in the map and if the current story is newer
              if (!userStoriesMap.containsKey(currentStory.userID) ||
                  currentStory.createdAt.isAfter(userStoriesMap[currentStory.userID]!.createdAt)) {
                userStoriesMap[currentStory.userID] = currentStory;
              }
            }
          }
          return userStoriesMap.values.toList(); // Return values from the map as a list
        });
  }
}
