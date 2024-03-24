// ignore_for_file: void_checks

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/feeds_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final supabase = Supabase.instance.client;
  PostRepository({required FirebaseFirestore firebaseFirestore});

  FutureVoid addPost(Feeds feeds) async {
    try {
      return right(
        await _posts.insert(
          feeds.toMap(),
        ),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> likeHandling(String docID, String uid) async {
    try {
      // Fetch the post's current likes
      final response = await _posts.select('likes').eq('feedID', docID).single();

      final List<dynamic>? currentLikes = response['likes'] as List<dynamic>?;
      List<dynamic> updatedLikes;

      if (currentLikes != null && currentLikes.contains(uid)) {
        // If the user's UID is already in the likes, remove it (unlike)
        updatedLikes = currentLikes.where((id) => id != uid).toList();
      } else {
        // Add the user's UID to the likes (like)
        updatedLikes = [...currentLikes ?? [], uid];
      }

      // Update the post with new likes and like count
      final updateResponse =
          await _posts.update({'likes': updatedLikes, 'likeCount': updatedLikes.length}).eq('feedID', docID);

      if (updateResponse.error != null) {
        throw updateResponse.error!;
      }
    } catch (error) {
      log('Error handling like: ${error.toString()}');
    }
  }

  Future<void> viewDocument(String docID, String uid) async {
    try {
      final doc = await _posts.select().eq("feedID", docID).single();
      final document = _posts;

      if (doc.isNotEmpty) {
        List<String> views = List.from(doc['views'] ?? []);
        if (!views.contains(uid)) {
          views.add(uid);
          await document.update({'views': views}).eq("feedID", docID);
        } else {}
      } else {}
    } catch (e) {
      Failure(e.toString());
    }
  }

  //dont forget to ignore the userID here from the feeds
  Future<List<Feeds>> getAllFeeds(String uid) async {
    try {
      // Query the posts table from Supabase
      final response = await _posts.select().neq("userID", uid);

      // Extract data from the response
      List<Feeds> feeds = (response).map((data) => Feeds.fromMap(data)).toList();

      // Calculate scores for each feed using the custom scoring function

      // Sort feeds based on the custom score in descending order
      feeds.sort((a, b) => b.score.compareTo(a.score));
      // Shuffle the feeds
      feeds.shuffle();

      return feeds;
    } catch (error) {
      // Handle error appropriately
      log("Error getting feeds: $error");
      rethrow;
    }
  }

// Custom scoring function
  int customScoringFunction(Map<String, dynamic> feedData) {
    // Constants for weights
    const double likesWeight = 0.6;
    const double commentsWeight = 0.3;
    const double recencyWeight = 0.1;

    // Extract relevant data from the feedData
    List likes = feedData['likes'] ?? [];
    int comments = feedData['commentCount'] ?? 0;
    Timestamp timestamp = feedData['createdAt'];

    // Calculate the score based on the weighted factors
    int score = (likes.length * likesWeight).toInt() +
        (comments * commentsWeight).toInt() +
        ((DateTime.now().millisecondsSinceEpoch - timestamp.millisecondsSinceEpoch) ~/
                (1000 * 60 * 60 * 24) *
                recencyWeight)
            .toInt();

    return score;
  }

  Stream<List<Feeds>> getUserFeeds(String uid) {
    return _posts.stream(primaryKey: ['feedID']).eq("userID", uid).map((event) {
          List<Feeds> feeds = [];
          for (var doc in event) {
            feeds.add(Feeds.fromMap(doc));
          }

          feeds.sort(
            (a, b) => Timestamp.fromMillisecondsSinceEpoch(int.parse(b.createdAt)).compareTo(
              Timestamp.fromMillisecondsSinceEpoch(
                int.parse(a.createdAt),
              ),
            ),
          );
          return feeds;
        });
  }

  Stream<List<Feeds>> getFollowingFeeds(List<dynamic> uids) {
    return _posts.stream(primaryKey: ['feedID']).order('createdAt', ascending: false).map((response) {
          final List<Map<String, dynamic>> data = response;
          List<Map<String, dynamic>> matchedFeeds = [];
          for (var item in data) {
            if (uids.contains(item['userID'])) {
              matchedFeeds.add(item);
            }
          }

          // If there are documents, map them to Feeds objects
          if (data.isNotEmpty) {
            return matchedFeeds.map((map) => Feeds.fromMap(map)).toList();
          } else {
            // If no documents match the criteria, return an empty list
            return [];
          }
        });
  }

  void sharePost(String feedID, String uid) async {
    try {
      final currentData = await _posts.select().eq("feedID", feedID).single();
      final isShared = currentData['shares']?.contains(uid) ?? false;
      if (!isShared) {
        List sharesList = currentData['shares'];
        sharesList.add(uid);
        final share = await _posts.update({"shares": sharesList}).eq("feedID", feedID);
        share;
      } else {
        log('is already shared with this user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Feeds>> getFeedByID(String feedId) {
    return _posts.stream(primaryKey: ['feedID']).eq('feedID', feedId).limit(1).map((response) {
          final List<Map<String, dynamic>> data = response;

          if (data.isNotEmpty) {
            return data.map((map) => Feeds.fromMap(map)).toList();
          } else {
            return [];
          }
        });
  }

  Stream<List<Feeds>> getFeedsByTags(String tag) {
    return _posts.stream(primaryKey: ['feedID']).map((response) {
      final List<Map<String, dynamic>> data = response;
      final List<Map<String, dynamic>> tagsFeedList = [];

      for (var feed in data) {
        if (feed['tags'].contains(tag)) {
          tagsFeedList.add(feed);
        }
      }

      if (data.isNotEmpty) {
        return tagsFeedList.map((map) => Feeds.fromMap(map)).toList();
      } else {
        return [];
      }
    });
  }

  Future<void> deletePost(String feedID) async {
    try {
      final deleted = _posts.update({
        'isShowed': false,
      }).eq("feedID", feedID);

      await deleted;
    } catch (e) {
      rethrow;
    }
  }

  SupabaseQueryBuilder get _posts => supabase.from(FirebaseConstant.postsCollection);
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   Future<void> updateAllDocuments() async {
//     try {
//       final CollectionReference collection = FirebaseFirestore.instance
//           .collection(FirebaseConstant.postsCollection);

//       QuerySnapshot querySnapshot = await collection.get();

//       for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//         await collection.doc(documentSnapshot.id).update({
//           "isCommentsOpen": true,
//         });
//       }

//       print('All documents updated successfully.');
//     } catch (e) {
//       print('Error updating documents: $e');
//     }
//   }

//   updateAllDocuments();
// }
