import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/providers/storage_repository_provider.dart';
import 'package:viblify_app/core/utils.dart';

import '../../../../models/comments.dart';
import '../../../auth/controller/auth_controller.dart';
import '../repository/comment_repository.dart';

final getAllCommentsProvider = StreamProvider.family((ref, String feedID) {
  final commentsController = ref.watch(commentsControllerProvider.notifier);
  return commentsController.getAllComments(feedID);
});
final getCommentsByCommentIDAndFeedID =
    StreamProvider.family<List<Comments>, Tuple2<String, dynamic>>((ref, tuple) {
  final commentsController = ref.watch(commentsControllerProvider.notifier);
  return commentsController.getCommentByID(tuple.item1, tuple.item2);
});
final deleteCommentProvider =
    FutureProvider.family<List<Comments>, Tuple2<String, dynamic>>((ref, tuple) async {
  final commentsController = ref.watch(commentsControllerProvider.notifier);
  return await commentsController.deleteComment(tuple.item1, tuple.item2);
});

final commentsControllerProvider = StateNotifierProvider<CommentController, bool>((ref) {
  final _repository = ref.watch(commentsRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return CommentController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class CommentController extends StateNotifier<bool> {
  CommentsRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommentController(
      {required CommentsRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
  void addComment({
    required File? image,
    required String content,
    required String gif,
    required String feedID,
    required BuildContext context,
    required List<String> tags,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    Comments comments = Comments(
      commentID: "",
      isShowed: true,
      gif: gif,
      createdAt: Timestamp.now(),
      content: content,
      userID: uid,
      photoUrl: "",
      tags: tags,
      replies: {},
      likes: [],
      score: 0,
    );

    // Check if feedID is still empty
    if (comments.commentID.isEmpty) {
      // If empty, generate a new ID
      comments = comments.copyWith(
        commentID: await generateUniqueFeedID(feedID),
      );
    }

    if (image != null) {
      final res = await _storageRepository.storeFile(
        path: 'comments/$uid',
        id: comments.commentID,
        file: image,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => comments = comments.copyWith(photoUrl: r),
      );
    }

    // Now add the post
    final result = await _repository.addPost(comments, feedID);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      Fluttertoast.showToast(msg: "تم نشر التعليق بنجاح");
    });
  }

  Future<String> generateUniqueFeedID(String feedID) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String generateNewFeedID() {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random.secure();
      return List.generate(28, (index) => chars[random.nextInt(chars.length)]).join();
    }

    String newCommentID = "";
    bool isUnique = false;

    while (!isUnique) {
      newCommentID = generateNewFeedID();

      final querySnapshot = await _firestore
          .collection(FirebaseConstant.postsCollection)
          .doc(feedID)
          .collection(FirebaseConstant.commentsCollection)
          .where('feedID', isEqualTo: newCommentID)
          .limit(1)
          .get();

      isUnique = querySnapshot.docs.isEmpty;
    }

    return newCommentID;
  }

  Stream<List<Comments>> getAllComments(String feedID) {
    return _repository.getAllComments(feedID);
  }

  Stream<List<Comments>> getCommentByID(String commentID, String feedID) {
    return _repository.getCommentByID(commentID, feedID);
  }

  void likeHundling(String feedID, String commenID, String uid) {
    _repository.likeHandling(feedID, commenID, uid);
  }

  Future deleteComment(String commentID, String feedID) async {
    return _repository.deleteComment(commentID, feedID);
  }
}
