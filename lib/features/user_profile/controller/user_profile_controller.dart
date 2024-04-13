// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/providers/storage_repository_provider.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/models/user_model.dart';

import '../../../models/feeds_model.dart';
import '../repository/user_profile_repository.dart';

final searchUsersProvider = StreamProvider.family((ref, String query) {
  return ref.watch(userProfileControllerProvider.notifier).searchCommunity(query);
});

final getFollowersProvider = StreamProvider.family((ref, String userID) {
  final userController = ref.watch(userProfileControllerProvider.notifier);
  return userController.getFollowersStream(userID);
});
final getFollowingProvider = StreamProvider.family((ref, String userID) {
  final userController = ref.watch(userProfileControllerProvider.notifier);
  return userController.getFollowingStream(userID);
});

final getUserLikeFeeds = FutureProvider.family((ref, String uid) async {
  final userController = ref.watch(userProfileControllerProvider.notifier);
  return userController.getUserLikedFeeds(uid);
});

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return UserProfileController(
      repository: repository, ref: ref, storageRepository: storageRepository);
});
final usernameTakenProvider = FutureProvider.family<bool, String>((ref, username) async {
  final repository = ref.read(userProfileRepositoryProvider);
  final user = ref.read(userProvider)!;
  return repository.isUsernameTaken(username, user.userID);
});

final isUserFollowingProvider = StreamProvider.family<bool, String>((ref, username) {
  final repository = ref.read(userProfileRepositoryProvider);
  final user = ref.read(userProvider)!;
  return repository.isFollowingTheUserStream(username, user.userID);
});

class UserProfileController extends StateNotifier<bool> {
  final UserRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController(
      {required UserRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void toggleFollow(String userID, String followerID) {
    state = true;
    _repository.toggleFollow(userID, followerID).then((value) => state = false);
  }

  void downloadImage(String imgUrl, BuildContext context) async {
    state = true;

    Fluttertoast.showToast(msg: "جاري التحميل ...", backgroundColor: Colors.blue[800]);

    final res = await _repository.downloadImage(imgUrl);

    state = false;

    res.fold((l) {
      showSnackBar(context, l.message);
      if (kDebugMode) {
        print(l.message);
      }
    }, (r) {
      Fluttertoast.showToast(msg: "تم تحميل الصورة بنجاح", backgroundColor: Colors.green[800]);
    });
  }

  void editProfileUser({
    required File? profileFile,
    required File? banner,
    required BuildContext context,
    required String name,
    required String bio,
    required bool stt,
    required String mbti,
    required String userName,
    required String location,
    required String link,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'users/avatar', id: user.userID, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (banner != null) {
      final res =
          await _storageRepository.storeFile(path: 'users/banner', id: user.userID, file: banner);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(bannerPic: r),
      );
    }
    user = user.copyWith(
        name: name,
        bio: bio,
        userName: userName,
        location: location,
        stt: stt,
        mbti: mbti,
        link: link);
    final res = await _repository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      context.pop();
    });
  }

  Future<void> updateActiveStatus(bool isOnline, String userID) async {
    _repository.updateActiveStatus(isOnline, userID);
  }

  Stream<List<UserModel>> searchCommunity(String query) {
    return _repository.searchUsers(query);
  }

  Future<void> updateProfileTheme(
      String uid, String color, String dividerColor, bool isThemeDark) async {
    _repository.updateProfileTheme(uid, color, dividerColor, isThemeDark);
  }

  Stream<List<dynamic>> getFollowersStream(String userID) {
    return _repository.getFollowersStream(userID);
  }

  Stream<List<dynamic>> getFollowingStream(String userID) {
    return _repository.getFollowingStream(userID);
  }

  Future<List<Feeds>> getUserLikedFeeds(String uid) async {
    return _repository.getUserLikedFeeds(uid);
  }
}
