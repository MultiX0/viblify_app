// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/dash/comments/repository/repository.dart';
import 'package:viblify_app/features/dash/comments/models/dash_comments_model.dart';

import '../../../../core/providers/storage_repository_provider.dart';
import '../../../notifications/db_notifications.dart';
import '../../../notifications/enums/notifications_enum.dart';

final getDashCommentsProvider = FutureProvider.family((ref, String dashID) async {
  final dashCommentsController = ref.watch(dashCommentsControllerProvider.notifier);
  return dashCommentsController.getAllComments(dashID);
});
final getDashCommentByID = StreamProvider.family((ref, String commentID) {
  final dashCommentsController = ref.watch(dashCommentsControllerProvider.notifier);

  return dashCommentsController.getCommentByID(commentID);
});

final dashCommentsControllerProvider = StateNotifierProvider<DashCommentsController, bool>((ref) {
  final _repository = ref.watch(dashCommentsRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return DashCommentsController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class DashCommentsController extends StateNotifier<bool> {
  final uuid = Uuid();
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
    required BuildContext context,
    required String dashID,
    required WidgetRef ref,
    required String dashUserID,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    DashCommentsModel dashCommentsModel = DashCommentsModel(
      userID: uid,
      dashID: dashID,
      likes: [],
      content: content,
      commentID: '',
    );

    if (dashCommentsModel.commentID.isEmpty) {
      dashCommentsModel = dashCommentsModel.copyWith(commentID: uuid.v4());
    }

    final result = await _repository.addComment(dashCommentsModel);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      showSnackBar(context, "Comment Posted Successfully");
      if (uid != dashUserID) {
        DbNotifications(
                dashID: dashID,
                userID: uid,
                to_userID: dashUserID,
                notification_content: content,
                notification_type: ActionType.dash_comment)
            .addNotification();
      }
      ref.refresh(getDashCommentsProvider(dashID));
    });
  }

  Future<List<DashCommentsModel>> getAllComments(String dashID) async {
    return _repository.getAllComments(dashID);
  }

  Future<void> likeHundling(String commentID, String uid, String dashID) async {
    _repository.likeHundling(commentID, uid, dashID);
  }

  Stream<DashCommentsModel> getCommentByID(String commentID) {
    return _repository.getCommentByID(commentID);
  }

  Future<void> deleteComment(
      String commentID, String dashID, BuildContext context, WidgetRef ref) async {
    _repository.deleteComment(commentID, dashID, context, ref);
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
