// ignore_for_file: void_checks, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/models/dash_comments_model.dart';

import '../../../../core/Constant/firebase_constant.dart';
import '../../../../core/type_defs.dart';
import '../../../notifications/db_notifications.dart';
import '../../../notifications/enums/notifications_enum.dart';

final dashCommentsRepositoryProvider = Provider((ref) {
  return DashCommentsRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class DashCommentsRepository {
  final supabase = Supabase.instance.client;
  DashCommentsRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _dashComments => supabase.from(FirebaseConstant.dashCommentsCollection);
  FutureVoid addComment(DashCommentsModel comment) async {
    try {
      return right(await _dashComments.insert(comment.toMap()).then((e) async {
        await supabase.rpc("comment_increment", params: {"count": 1, "row_id": comment.dashID});
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<DashCommentsModel>> getAllComments(String dashID) async {
    try {
      final data =
          await _dashComments.select().eq("dashID", dashID).order('createdAt', ascending: false);

      final List<DashCommentsModel> comments =
          data.map<DashCommentsModel>((data) => DashCommentsModel.fromMap(data)).toList();

      return comments;
    } catch (error) {
      Failure("Error getting dashes: $error");
      rethrow;
    }
  }

  Stream<DashCommentsModel> getCommentByID(String commentID) {
    return _dashComments
        .stream(primaryKey: ['commentID'])
        .eq("commentID", commentID)
        .map((dash) => DashCommentsModel.fromMap(dash.first));
  }

  Future<void> likeHundling(String commentID, String userID, String dashID) async {
    try {
      var ref = await _dashComments.select('*').eq("commentID", commentID).single();
      var data = await _dashComments.select('*').eq("commentID", commentID).single();
      var commentOwner = data['userID'];
      List<dynamic> likes = ref['likes'];
      bool isLiked = likes.contains(userID);
      if (isLiked) {
        var newLikes = likes;
        newLikes.remove(userID);
        await _dashComments.update({"likes": newLikes}).eq("commentID", commentID);
      } else {
        var newLikes = likes;
        newLikes.add(userID);
        await _dashComments.update({"likes": newLikes}).eq("commentID", commentID);
        if (commentOwner != userID) {
          DbNotifications(
                  userID: userID,
                  to_userID: commentOwner,
                  notification_type: ActionType.dash_comment_like,
                  dashID: dashID)
              .addNotification();
        }
      }
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }

  Future<void> deleteComment(
      String commentID, String dashID, BuildContext context, WidgetRef ref) async {
    try {
      var doc = _dashComments.delete().eq("commentID", commentID);
      doc.then(
        (e) => showSnackBar(context, "تم حذف التعليق بنجاح"),
      );
      await supabase.rpc("comment_decrement", params: {"count": 1, "row_id": dashID});
    } catch (e) {
      log(e.toString());
      errorSnackBar(context);
      throw Failure(e.toString());
    }
  }
}
