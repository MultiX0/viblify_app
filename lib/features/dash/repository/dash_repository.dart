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

  SupabaseQueryBuilder get _dash =>
      supabase.from(FirebaseConstant.dashCollection);
  FutureVoid addPost(Dash dash) async {
    try {
      return right(await supabase.from('dashs').insert(dash.toMap()));
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

      final List<Dash> dashes =
          data.map<Dash>((data) => Dash.fromMap(data)).toList();
      dashes.shuffle();

      return dashes;
    } catch (error) {
      Failure("Error getting dashes: $error");
      rethrow;
    }
  }

  Future<List<Dash>> getRecommendedDash(
      String id, List<dynamic> labels, List<dynamic> tags) async {
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
}
