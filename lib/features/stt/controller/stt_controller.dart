import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/stt/repository/stt_repository.dart';
import 'package:viblify_app/models/notifications_model.dart';
import 'package:viblify_app/models/stt_model.dart';

import '../../../core/utils.dart';

final getAllSttsProvider = StreamProvider.family((ref, String uid) {
  final sttController = ref.watch(sttControllerProvider.notifier);

  return sttController.getAllStts(uid);
});
final getSttByIdProvider = StreamProvider.family<List<STT>, Tuple2<String, dynamic>>((ref, tuple) {
  return ref.watch(sttControllerProvider.notifier).getSttByID(tuple.item1, tuple.item2);
});

final sttControllerProvider = StateNotifierProvider<SttController, bool>((ref) {
  final _repository = ref.watch(sttRepositoryProvider);
  return SttController(
    repository: _repository,
    ref: ref,
  );
});

class SttController extends StateNotifier<bool> {
  SttRepository _repository;
  final Ref _ref;
  SttController({
    required SttRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(false);

  void addStt(
      {required String message, required String userID, required BuildContext context}) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    STT stt = STT(
      isShowed: true,
      message: message,
      createdAt: Timestamp.now(),
      userID: uid,
      sttID: "",
    );

    if (stt.sttID.isEmpty) {
      stt = stt.copyWith(sttID: await generateUniqueSttID(userID));
    }
    final result = await _repository.addStt(stt, userID);
    NotificationsModel notificationsModel = NotificationsModel(
      to_userID: userID,
      userID: uid,
      feedID: '',
      notification_type: '',
      notification: "لقد وصلت رسالة جديدة من مجهول",
      sttID: stt.sttID,
      createdAt: Timestamp.now(),
    );
    _repository.addNotification(notificationsModel);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      Fluttertoast.showToast(msg: "تم ارسال الرسالة بنجاح");
      context.pop();
    });
  }

  Future<String> generateUniqueSttID(String userID) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String generateNewSttID() {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random.secure();
      return List.generate(28, (index) => chars[random.nextInt(chars.length)]).join();
    }

    String newFeedID = "";
    bool isUnique = false;

    while (!isUnique) {
      newFeedID = generateNewSttID();

      final querySnapshot = await _firestore
          .collection(FirebaseConstant.usersCollection)
          .doc(userID)
          .collection(FirebaseConstant.sttCollection)
          .where('feedID', isEqualTo: newFeedID)
          .limit(1)
          .get();

      isUnique = querySnapshot.docs.isEmpty;
    }

    return newFeedID;
  }

  Stream<List<STT>> getAllStts(String uid) {
    return _repository.getAllStts(uid);
  }

  Stream<List<STT>> getSttByID(String sttID, String userID) {
    return _repository.getSttByID(sttID, userID);
  }

  Future deleteStt(String userID, String sttID) async {
    return _repository.deleteStt(userID, sttID);
  }
}
