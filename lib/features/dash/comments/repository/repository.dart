// ignore_for_file: void_checks

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/models/dash_comments_model.dart';
import 'package:viblify_app/models/dash_model.dart';

import '../../../../core/Constant/firebase_constant.dart';
import '../../../../core/type_defs.dart';

final dashCommentsRepositoryProvider = Provider((ref) {
  return DashCommentsRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class DashCommentsRepository {
  final supabase = Supabase.instance.client;
  DashCommentsRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _dash => supabase.from(FirebaseConstant.dashCollection);
  FutureVoid addComment(DashCommentsModel comment) async {
    try {
      return right(await _dash.insert(comment.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<Dash>> getAllComments(String dashID) async {
    try {
      final data = await _dash.select();

      // .neq('userID', uid); // does

      final List<Dash> dashes = data.map<Dash>((data) => Dash.fromMap(data)).toList();
      dashes.shuffle();

      return dashes;
    } catch (error) {
      Failure("Error getting dashes: $error");
      rethrow;
    }
  }

  Stream<Dash> getCommentByID(String dashID) {
    return _dash
        .stream(primaryKey: ['dashID'])
        .eq("dashID", dashID)
        .map((dash) => Dash.fromMap(dash.first));
  }

  Future<void> likeHundling(String dashID, String userID) async {
    try {
      var ref = await _dash.select('*').eq("dashID", dashID).single();
      List<dynamic> likes = ref['likes'];
      bool isLiked = likes.contains(userID);
      if (isLiked) {
        var newLikes = likes;
        newLikes.remove(userID);
        await _dash.update({"likes": newLikes}).eq("dashID", dashID);
      } else {
        var newLikes = likes;
        newLikes.add(userID);
        await _dash.update({"likes": newLikes}).eq("dashID", dashID);
      }
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }
}
