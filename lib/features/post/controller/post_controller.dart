import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/providers/storage_repository_provider.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/repository/post_repository.dart';
import 'package:viblify_app/models/feeds_model.dart';

final getAllFeedsProvider = FutureProvider.family((ref, String uid) {
  final communityController = ref.watch(postControllerProvider.notifier);
  return communityController.getAllFeeds(uid);
});

final deleteFeedProvider = FutureProvider.family((ref, String feedID) {
  final communityController = ref.watch(postControllerProvider.notifier);
  return communityController.getAllFeeds(feedID);
});

final getFeedByID = StreamProvider.family((ref, String feedID) {
  final communityController = ref.watch(postControllerProvider.notifier);
  return communityController.getFeedByID(feedID);
});

final getUserFeedsProvider = StreamProvider.family((ref, String uid) {
  final communityController = ref.watch(postControllerProvider.notifier);
  return communityController.getUserFeeds(uid);
});
final getFeedsByTagsProvider = StreamProvider.family((ref, String tag) {
  final communityController = ref.watch(postControllerProvider.notifier);
  return communityController.getFeedsByTags(tag);
});

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final _repository = ref.watch(postRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return PostController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class PostController extends StateNotifier<bool> {
  PostRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void addPost({
    required File? image,
    required String gif,
    required String sttID,
    required String content,
    required String videoID,
    required BuildContext context,
    required List<String> tags,
    required bool isCommentsOpen,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    // Calculate the score for the new post using the custom scoring function
    int score = _repository.customScoringFunction({
      'likes': [],
      'commentCount': 0,
      'createdAt': Timestamp.now(),
      // Add other relevant data for scoring
    });

    Feeds feeds = Feeds(
      shares: [],
      isCommentsOpen: isCommentsOpen,
      isShowed: true,
      youtubeVideoID: videoID,
      feedID: "",
      sttID: sttID,
      gif: gif,
      createdAt: Timestamp.now(),
      content: content,
      userID: uid,
      photoUrl: "",
      tags: tags,
      likeCount: 0,
      likes: [],
      views: [],
      commentCount: 0,
      score: score, // Use the calculated score
    );

    // Check if feedID is still empty
    if (feeds.feedID.isEmpty) {
      // If empty, generate a new ID
      feeds = feeds.copyWith(feedID: await generateUniqueFeedID());
    }

    if (image != null) {
      final res = await _storageRepository.storeFile(
        path: 'feeds/$uid',
        id: feeds.feedID,
        file: image,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => feeds = feeds.copyWith(photoUrl: r),
      );
    }

    // Now add the post
    final result = await _repository.addPost(feeds);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      showSnackBar(context, "Post Created Successfully");
      context.pop();
    });
  }

  Future<String> generateUniqueFeedID() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String generateNewFeedID() {
      const chars = '0123456789';
      final random = Random.secure();
      return List.generate(10, (index) => chars[random.nextInt(chars.length)])
          .join();
    }

    String newFeedID = "";
    bool isUnique = false;

    while (!isUnique) {
      newFeedID = generateNewFeedID();

      final querySnapshot = await _firestore
          .collection(FirebaseConstant.postsCollection)
          .where('feedID', isEqualTo: newFeedID)
          .limit(1)
          .get();

      isUnique = querySnapshot.docs.isEmpty;
    }

    return newFeedID;
  }

  void likeHundling(String docID, String uid) {
    _repository.likeHandling(docID, uid);
  }

  void viewDocument(String docID, String uid) {
    _repository.viewDocument(docID, uid);
  }

  void sharePost(String docID, String uid) {
    _repository.sharePost(docID, uid);
  }

  Future<List<Feeds>> getAllFeeds(String uid) {
    return _repository.getAllFeeds(uid);
  }

  Stream<List<Feeds>> getFeedByID(String feedID) {
    return _repository.getFeedByID(feedID);
  }

  Stream<List<Feeds>> getUserFeeds(String uid) {
    return _repository.getUserFeeds(uid);
  }

  Stream<List<Feeds>> getFeedsByTags(String tag) {
    return _repository.getFeedsByTags(tag);
  }

  Future deletePost(String feedID) {
    return _repository.deletePost(feedID);
  }
}
