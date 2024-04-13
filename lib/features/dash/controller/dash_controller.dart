import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tuple/tuple.dart';
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
final getUserDashesProvider = FutureProvider.family((ref, String userID) {
  final dashController = ref.watch(dashControllerProvider.notifier);

  return dashController.getUserDashs(userID);
});

final getRecommendedDashProvider = FutureProvider.family((ref, Tuple2 tuple2) {
  final dashController = ref.watch(dashControllerProvider.notifier);

  return dashController.getRecommendedDash(tuple2.item1, tuple2.item2);
});

final getDashByIDProvider = StreamProvider.family((ref, String dashID) {
  final dashController = ref.watch(dashControllerProvider.notifier);

  return dashController.getDashByID(dashID);
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
  DashController(
      {required DashRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void addDash({
    required File? file,
    required String description,
    required String title,
    required BuildContext context,
    required bool isCommentsOpen,
    required List<dynamic> labels,
  }) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";

    Dash dash = Dash(
      userID: uid,
      dashID: "",
      likes: [],
      views: [],
      shares: [],
      contentUrl: "",
      description: description,
      commentCount: 0,
      createdAt: Timestamp.now().millisecondsSinceEpoch.toString(),
      labels: labels,
    );

    if (dash.dashID.isEmpty) {
      dash = dash.copyWith(dashID: await generateUniqueDashID());
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

  Future<String> generateUniqueDashID() async {
    String generateNewDashID() {
      const chars = '0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
      final random = Random.secure();
      return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
    }

    String newDashID = "";
    bool isUnique = false;
    final supabase = Supabase.instance.client;

    while (!isUnique) {
      newDashID = generateNewDashID();

      final querySnapshot = await supabase
          .from(FirebaseConstant.dashCollection)
          .select()
          .eq("dashID", newDashID)
          .limit(1);

      isUnique = querySnapshot.isEmpty;
    }

    return newDashID;
  }

  Future<List<Dash>> getAllDashes(String uid) async {
    return _repository.getAllDashes(uid);
  }

  Future<List<Dash>> getUserDashs(String uid) async {
    return _repository.getUserDashs(uid);
  }

  Future<List<Dash>> getRecommendedDash(String id, List<dynamic> labels) async {
    return _repository.getRecommendedDash(id, labels);
  }

  Future<void> addUserToViews(String dashID, String userID) async {
    _repository.addUserToViews(dashID, userID);
  }

  Future<void> likeHundling(String dashID, String userID) async {
    _repository.likeHundling(dashID, userID);
  }

  Stream<Dash> getDashByID(String dashID) {
    return _repository.getDashByID(dashID);
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
