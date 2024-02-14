import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/storage_repository_provider.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/community/repository/community_repository.dart';
import 'package:viblify_app/models/community_model.dart';

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communitControllerProvider.notifier).searchCommunity(query);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communitControllerProvider.notifier);
  return communityController.getCommunityByName(name);
});

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communitControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communitControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final _repository = ref.watch(communityRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return CommunityController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

final communityNameTakenProvider =
    FutureProvider.family<bool, String>((ref, name) async {
  final repository = ref.read(communityRepositoryProvider);

  return repository.isUsernameTaken(name);
});

class CommunityController extends StateNotifier<bool> {
  CommunitRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunitRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.userID ?? "";
    Community community = Community(
      id: name,
      name: name,
      banner: Constant.bannerDefault,
      avatar: Constant.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final result = await _repository.createCommunity(community);
    state = false;
    result.fold((l) => showSnackBar(context, "the name is already used"), (r) {
      showSnackBar(context, "Community Created Successfully");
      Navigator.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.userID)) {
      res = await _repository.leaveCommunity(community.name, user.userID);
    } else {
      res = await _repository.joinCommunity(community.name, user.userID);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.userID)) {
        showSnackBar(context, "Community left successfully");
      } else {
        showSnackBar(context, "Community joined successfully");
      }
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.userID;
    return _repository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _repository.getCommunityByName(name);
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _repository.searchCommunity(query);
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _repository.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Navigator.of(context).pop());
  }

  void editCommunity(
      {required File? profileFile,
      required File? communityBanner,
      required BuildContext context,
      required Community community}) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'communities/avatar', id: community.name, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }
    if (communityBanner != null) {
      final res = await _storageRepository.storeFile(
          path: 'communities/banner',
          id: community.name,
          file: communityBanner);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }
    final res = await _repository.editCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Navigator.of(context).pop());
  }
}
