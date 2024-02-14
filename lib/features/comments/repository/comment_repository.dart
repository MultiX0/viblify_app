import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/failure.dart';

import '../../../core/Constant/firebase_constant.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';
import '../../../models/comments.dart';

final commentsRepositoryProvider = Provider((ref) {
  return CommentsRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class CommentsRepository {
  final FirebaseFirestore _firebaseFirestore;
  CommentsRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;
  CollectionReference get _comments =>
      _firebaseFirestore.collection(FirebaseConstant.postsCollection);

  FutureVoid addPost(Comments comments, String feedID) async {
    try {
      return right(_comments
          .doc(feedID)
          .collection(FirebaseConstant.commentsCollection)
          .doc(comments.commentID)
          .set(comments.toMap())
          .then((value) async {
        int commentCount = await getCollectionSize(feedID);
        _comments.doc(feedID).update({"commentCount": commentCount});
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<int> getCollectionSize(String feedID) async {
    QuerySnapshot querySnapshot = await _comments
        .doc(feedID)
        .collection(FirebaseConstant.commentsCollection)
        .where('isShowed', isEqualTo: true)
        .get();

    return querySnapshot.size;
  }

  Stream<List<Comments>> getAllComments(String feedID) {
    return _comments
        .doc(feedID)
        .collection(FirebaseConstant.commentsCollection)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) {
      List<Comments> comments = [];
      for (var doc in event.docs) {
        comments.add(
          Comments.fromMap(
            doc.data(),
          ),
        );
      }
      return comments;
    });
  }

  Stream<List<Comments>> getCommentByID(String commentID, String feedId) {
    return _comments
        .doc(feedId)
        .collection(FirebaseConstant.commentsCollection)
        .where('commentID', isEqualTo: commentID)
        .snapshots()
        .map((event) {
      if (event.docs.isNotEmpty) {
        // If there are documents, directly return the single feed
        return [
          Comments.fromMap(event.docs.first.data() as Map<String, dynamic>)
        ];
      } else {
        // If no documents match the criteria, return an empty list
        return [];
      }
    });
  }

  void likeHandling(
    String feedID,
    String commentID,
    String uid,
  ) async {
    final likingRef = _comments
        .doc(feedID)
        .collection(FirebaseConstant.commentsCollection)
        .doc(commentID);

    // Fetch the current data
    final currentData = await likingRef.get();
    final isLiked = currentData['likes']?.contains(uid) ?? false;

    // Update the likes and likeCount fields
    if (isLiked) {
      await likingRef.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await likingRef.update({
        'likes': FieldValue.arrayUnion([uid]),
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

  Future<void> deleteComment(String commentID, String feedID) async {
    try {
      final deleted = _comments
          .doc(feedID)
          .collection(FirebaseConstant.commentsCollection)
          .doc(commentID)
          .update({
        'isShowed': false,
      }).then((value) {
        _comments.doc(feedID).update({
          'commentCount': FieldValue.increment(-1),
        });
      });

      await deleted;
    } catch (e) {
      rethrow;
    }
  }
}
