import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/dash/repository/dash_repository.dart';
import 'package:viblify_app/models/dash_model.dart';

import '../../../core/Constant/firebase_constant.dart';
import '../../../core/providers/storage_repository_provider.dart';

final getAllDashesProvider = FutureProvider((ref) {
  final myID = ref.read(userProvider)?.userID ?? "";
  final dashController = ref.watch(dashControllerProvider.notifier);

  return dashController.getAllDashes(myID);
});

final dashControllerProvider = StateNotifierProvider<DashController, bool>((ref) {
  final _repository = ref.watch(dashRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return DashController(repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class DashController extends StateNotifier<bool> {
  DashRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  DashController({required DashRepository repository, required Ref ref, required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void addDash({
    required File? file,
    required String description,
    required String title,
    required BuildContext context,
    required List<dynamic> tags,
    required bool isCommentsOpen,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    Dash dash = Dash(
      userID: uid,
      dashID: "",
      likes: [],
      views: 0,
      shares: [],
      tags: tags,
      contentUrl: "",
      description: description,
      commentCount: 0,
      createdAt: Timestamp.now().millisecondsSinceEpoch.toString(),
    );

    if (dash.dashID.isEmpty) {
      dash = dash.copyWith(dashID: await generateUniqueFeedID());
    }

    if (file != null) {
      final res = await _storageRepository.storeFile(
        path: 'dashs/$uid',
        id: dash.dashID,
        file: file,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => dash = dash.copyWith(contentUrl: r),
      );
    }

    final result = await _repository.addPost(dash);

    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) async {
      showSnackBar(context, "Dash Created Successfully");
      context.pop();
    });
  }

  Future<String> generateUniqueFeedID() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String generateNewFeedID() {
      const chars = '0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
      final random = Random.secure();
      return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
    }

    String newDashID = "";
    bool isUnique = false;

    while (!isUnique) {
      newDashID = generateNewFeedID();

      final querySnapshot = await firestore
          .collection(FirebaseConstant.dashCollection)
          .where('feedID', isEqualTo: newDashID)
          .limit(1)
          .get();

      isUnique = querySnapshot.docs.isEmpty;
    }

    return newDashID;
  }

  Future<List<Dash>> getAllDashes(String uid) async {
    return _repository.getAllDashes(uid);
  }
}
