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
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({required FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore;

  FutureVoid addPost(Feeds feeds) async {
    try {
      return right(_posts.doc(feeds.feedID).set(feeds.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> likeHandling(String docID, String uid) async {
    try {
      // Fetch the post's current likes
      final response = await supabase.from('posts').select('likes').eq('feedID', docID).single();

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
      final updateResponse = await supabase
          .from('posts')
          .update({'likes': updatedLikes, 'likeCount': updatedLikes.length}).eq('feedID', docID);

      if (updateResponse.error != null) {
        throw updateResponse.error!;
      }
    } catch (error) {
      print('Error handling like: ${error.toString()}');
    }
  }

  Future<void> viewDocument(String docID, String uid) async {
    try {
      DocumentSnapshot doc = await _posts.doc(docID).get();
      final document = _posts.doc(docID);

      if (doc.exists) {
        List<String> views = List.from(doc['views'] ?? []);
        if (!views.contains(uid)) {
          views.add(uid);
          await document.update({'views': views});
        } else {}
      } else {}
    } catch (e) {
      Failure(e.toString());
    }
  }

  Future<List<Feeds>> getAllFeeds(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _posts.where('userID', isNotEqualTo: uid).get() as QuerySnapshot<Map<String, dynamic>>;

      List<Feeds> feeds = snapshot.docs
          .map(
            (doc) => Feeds.fromMap(
              doc.data(),
            ),
          )
          .toList();

      // Calculate scores for each feed using the custom scoring function
      feeds.forEach((feed) {
        feed.score = customScoringFunction(feed.toMap());
      });

      // Sort feeds based on the custom score in descending order
      feeds.sort((a, b) => b.score.compareTo(a.score));
      feeds.shuffle();
      return feeds;
    } catch (error) {
      // Handle error appropriately
      print("Error getting feeds: $error");
      throw error;
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
    return _posts.where("userID", isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map((event) {
      List<Feeds> feeds = [];
      for (var doc in event.docs) {
        feeds.add(Feeds.fromMap(doc.data() as Map<String, dynamic>));
      }
      return feeds;
    });
  }

  Stream<List<Feeds>> getFollowingFeeds(List<dynamic> uids) {
    return _posts.orderBy('createdAt', descending: true).where("userID", whereIn: uids).snapshots().map((event) {
      List<Feeds> feeds = [];
      for (var doc in event.docs) {
        feeds.add(Feeds.fromMap(doc.data() as Map<String, dynamic>));
      }
      return feeds;
    });
  }

  void sharePost(String feedID, String uid) async {
    try {
      final postRef = _posts.doc(feedID);
      final currentData = await postRef.get();
      final isShared = currentData['shares']?.contains(uid) ?? false;
      if (!isShared) {
        final share = await _posts.doc(feedID).update({
          'shares': FieldValue.arrayUnion([uid]),
        });
        share;
      } else {
        print('is already shared with this user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Feeds>> getFeedByID(String feedId) {
    return _posts.where("feedID", isEqualTo: feedId).snapshots().map((event) {
      if (event.docs.isNotEmpty) {
        // If there are documents, directly return the single feed
        return [Feeds.fromMap(event.docs.first.data() as Map<String, dynamic>)];
      } else {
        // If no documents match the criteria, return an empty list
        return [];
      }
    });
  }

  Stream<List<Feeds>> getFeedsByTags(String tag) {
    return _posts.where("tags", arrayContains: tag).snapshots().map((event) {
      List<Feeds> feeds = [];
      for (var doc in event.docs) {
        feeds.add(Feeds.fromMap(doc.data() as Map<String, dynamic>));
      }
      return feeds;
    });
  }

  Future<void> deletePost(String feedID) async {
    try {
      final deleted = _posts.doc(feedID).update({
        'isShowed': false,
      });

      await deleted;
    } catch (e) {
      rethrow;
    }
  }

  CollectionReference get _posts => _firebaseFirestore.collection(FirebaseConstant.postsCollection);
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
