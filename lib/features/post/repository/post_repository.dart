import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/feeds_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  FutureVoid addPost(Feeds feeds) async {
    try {
      return right(_posts.doc(feeds.feedID).set(feeds.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void likeHandling(String docID, String uid) async {
    final likingRef = _posts.doc(docID);

    // Fetch the current data
    final currentData = await likingRef.get();
    final isLiked = currentData['likes']?.contains(uid) ?? false;

    // Update the likes and likeCount fields
    if (isLiked) {
      await likingRef.update({
        'likes': FieldValue.arrayRemove([uid]),
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      await likingRef.update({
        'likes': FieldValue.arrayUnion([uid]),
        'likeCount': FieldValue.increment(1),
      });
    }

    // Fetch the updated data after the like handling
    final updatedData = await likingRef.get();

    // Calculate the new score using your custom scoring function
    int newScore =
        customScoringFunction(updatedData.data() as Map<String, dynamic>);

    // Update the score field in Firestore
    await likingRef.update({
      'score': newScore,
    });
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
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _posts
          .where('userID', isNotEqualTo: uid)
          .get() as QuerySnapshot<Map<String, dynamic>>;

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
        ((DateTime.now().millisecondsSinceEpoch -
                    timestamp.millisecondsSinceEpoch) ~/
                (1000 * 60 * 60 * 24) *
                recencyWeight)
            .toInt();

    return score;
  }

  Stream<List<Feeds>> getUserFeeds(String uid) {
    return _posts
        .where("userID", isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) {
      List<Feeds> feeds = [];
      for (var doc in event.docs) {
        feeds.add(Feeds.fromMap(doc.data() as Map<String, dynamic>));
      }
      return feeds;
    });
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

  CollectionReference get _posts =>
      _firebaseFirestore.collection(FirebaseConstant.postsCollection);
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
