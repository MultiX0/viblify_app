import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/dash/comments/repository/repository.dart';
import 'package:viblify_app/models/dash_comments_model.dart';
import 'package:viblify_app/models/dash_model.dart';

import '../../../../core/Constant/firebase_constant.dart';
import '../../../../core/providers/storage_repository_provider.dart';

final getDashCommentsProvider = FutureProvider.family((ref, String dashID) async {
  final dashCommentsController = ref.watch(dashCommentsControllerProvider.notifier);
  return dashCommentsController.getAllComments(dashID);
});

final dashCommentsControllerProvider = StateNotifierProvider<DashCommentsController, bool>((ref) {
  final _repository = ref.watch(dashCommentsRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return DashCommentsController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class DashCommentsController extends StateNotifier<bool> {
  DashCommentsRepository _repository;
  final Ref _ref;
  DashCommentsController(
      {required DashCommentsRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        super(false);

  void addComment({
    required String content,
    required String title,
    required BuildContext context,
    required bool isCommentsOpen,
    required List<dynamic> labels,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    DashCommentsModel dashCommentsModel = DashCommentsModel(
      userID: uid,
      dashID: "",
      likes: [],
      content: content,
      commentID: '',
      createdAt: Timestamp.now().millisecondsSinceEpoch.toString(),
    );

    if (dashCommentsModel.dashID.isEmpty) {
      dashCommentsModel = dashCommentsModel.copyWith(dashID: await generateUniqueCommentID());
    }

    final result = await _repository.addComment(dashCommentsModel);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      showSnackBar(context, "Comment Posted Successfully");
      context.pop();
    });
  }

  Future<String> generateUniqueCommentID() async {
    String generateNewCommentID() {
      const chars = '0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
      final random = Random.secure();
      return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
    }

    String newDashID = "";
    bool isUnique = false;
    final supabase = Supabase.instance.client;

    while (!isUnique) {
      newDashID = generateNewCommentID();

      final querySnapshot = await supabase
          .from(FirebaseConstant.dashCommentsCollection)
          .select()
          .eq("commentID", newDashID)
          .limit(1);

      isUnique = querySnapshot.isEmpty;
    }

    return newDashID;
  }

  Future<List<Dash>> getAllComments(String dashID) async {
    return _repository.getAllComments(dashID);
  }

  Stream<Dash> getCommentByID(String dashID) {
    return _repository.getCommentByID(dashID);
  }
}

// Future<void> addToSupabase(Dash dash) async {
//   final supabase = Supabase.instance.client;

//   try {
//     await supabase.from('dashs').insert(dash.toMap());
//   } catch (e) {
//     rethrow;
//   }
// }
