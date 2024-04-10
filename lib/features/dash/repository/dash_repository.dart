// ignore_for_file: void_checks

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/models/dash_model.dart';

import '../../../core/Constant/firebase_constant.dart';
import '../../../core/type_defs.dart';

final dashRepositoryProvider = Provider((ref) {
  return DashRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class DashRepository {
  final supabase = Supabase.instance.client;
  DashRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _dash => supabase.from(FirebaseConstant.dashCollection);
  FutureVoid addPost(Dash dash) async {
    try {
      return right(await _dash.insert(dash.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<Dash>> getAllDashes(String uid) async {
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

  Stream<Dash> getDashByID(String dashID) {
    return _dash
        .stream(primaryKey: ['dashID'])
        .eq("dashID", dashID)
        .map((dash) => Dash.fromMap(dash.first));
  }

  Future<List<Dash>> getRecommendedDash(String id, List<dynamic> labels) async {
    try {
      final result = await _dash.select();
      final filteredData = result.where((dash) {
        final dashLabels = dash['labels'] as List<dynamic>;
        return labels.any((label) => dashLabels.contains(label));
      }).toList();

      List<Dash> dashes = filteredData
          .map(
            (doc) => Dash.fromMap(doc),
          )
          .toList();

      // filter out dashes where dashID is equal to the provided id
      dashes = dashes.where((dash) => dash.dashID != id).toList();

      // Shuffle the dashes
      dashes.shuffle();

      return dashes;
    } catch (error) {
      log("Error getting feeds: $error");
      rethrow;
    }
  }

  Future<void> addUserToViews(String dashID, String userID) async {
    try {
      var ref = await _dash.select('*').eq("dashID", dashID).single();
      List<dynamic> views = ref['views'];
      var isViewd = views.contains(userID);
      if (isViewd) {
        log("already 5hara");
      } else {
        List<dynamic> newViews = views;
        newViews.add(userID);
        await _dash.update({"views": newViews}).eq("dashID", dashID);
        log("done here");
        log("added complete");
      }
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
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
