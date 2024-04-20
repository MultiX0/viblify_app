// ignore_for_file: void_checks, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
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

  Stream<List<Story>> getAllStories(String _userID, List<dynamic> myFollowing) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return _stories
        .stream(primaryKey: ['storyID'])
        .gt("createdAt", yesterday.millisecondsSinceEpoch)
        .order("createdAt", ascending: false)
        .map((data) {
          Map<String, Story> latestStoriesMap = {}; // Map to store the latest story for each user

          for (var story in data) {
            final currentStory = Story.fromMap(story);
            if (myFollowing.contains(currentStory.userID) || currentStory.userID == _userID) {
              if (!latestStoriesMap.containsKey(currentStory.userID) ||
                  currentStory.createdAt
                      .isAfter(latestStoriesMap[currentStory.userID]!.createdAt)) {
                // If the user ID is not yet in the map or the current story is newer, update the map
                latestStoriesMap[currentStory.userID] = currentStory;
              }
            }
          }

          // Convert map values to list
          List<Story> latestStories = latestStoriesMap.values.toList();

          // Sort the list by creation date in descending order (latest first)
          latestStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return latestStories;
        });
  }

  Stream<List<Story>> getUserStories(String userID) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _stories
        .stream(primaryKey: ['storyID'])
        .gt("createdAt", yesterday.millisecondsSinceEpoch)
        .order("createdAt", ascending: true)
        .map((data) {
          List<Story> userStories = [];
          for (var storyMap in data) {
            final Story story = Story.fromMap(storyMap);
            if (story.userID == userID) {
              userStories.add(story);
            }
          }
          return userStories;
        });
  }

  Future<void> viewStory(String storyID, String userID) async {
    try {
      var ref = await _stories.select('*').eq("storyID", storyID).single();
      List<dynamic> views = ref['views'];
      List<dynamic> new_views = views;
      if (!views.contains(userID)) {
        new_views.add(userID);
      } else {
        log("already seen it");
      }

      await _stories.update({"views": new_views}).eq("storyID", storyID);
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }
}
