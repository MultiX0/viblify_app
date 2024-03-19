import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/models/dash_model.dart';

import '../../../core/Constant/firebase_constant.dart';
import '../../../core/type_defs.dart';

final dashRepositoryProvider = Provider((ref) {
  return DashRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class DashRepository {
  final FirebaseFirestore _firebaseFirestore;
  DashRepository({required FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _dash => _firebaseFirestore.collection(FirebaseConstant.dashCollection);

  FutureVoid addPost(Dash dash) async {
    try {
      return right(_dash.doc(dash.dashID).set(dash.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<Dash>> getAllDashes(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _dash
          // .where('userID', isNotEqualTo: uid)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      List<Dash> dashs = snapshot.docs
          .map(
            (doc) => Dash.fromMap(
              doc.data(),
            ),
          )
          .toList();

      dashs.shuffle();

      return dashs;
    } catch (error) {
      log("Error getting feeds: $error");
      rethrow;
    }
  }

  Future<List<Dash>> getDash(String id) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _dash.where('dashID', isNotEqualTo: id).get() as QuerySnapshot<Map<String, dynamic>>;

      List<Dash> dashs = snapshot.docs
          .map(
            (doc) => Dash.fromMap(
              doc.data(),
            ),
          )
          .toList();

      dashs.shuffle();

      return dashs;
    } catch (error) {
      log("Error getting feeds: $error");
      rethrow;
    }
  }
}
