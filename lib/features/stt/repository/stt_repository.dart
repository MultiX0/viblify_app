import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/notifications_model.dart';
import 'package:viblify_app/models/stt_model.dart';

import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';

final sttRepositoryProvider = Provider((ref) {
  return SttRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class SttRepository {
  final FirebaseFirestore _firebaseFirestore;
  SttRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _stts =>
      _firebaseFirestore.collection(FirebaseConstant.usersCollection);

  FutureVoid addStt(STT stt, String userID) async {
    try {
      return right(
          _stts.doc(userID).collection('stt').doc(stt.sttID).set(stt.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> addNotification(
      String userID, NotificationsModel notificationsModel) async {
    try {
      await _stts.doc(userID).update({
        'notifications': FieldValue.arrayUnion([notificationsModel.toMap()]),
      });
      print('notifications added successfully!');
    } catch (e) {
      print('Error adding notifications: $e');
    }
  }
}
