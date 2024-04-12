// ignore_for_file: unused_result

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/features/notifications/repository/repository.dart';
import 'package:viblify_app/models/notifications_model.dart';

import '../../../../core/providers/storage_repository_provider.dart';

final getNotificationsProvider = FutureProvider.family((ref, String userID) async {
  final dashCommentsController = ref.watch(notificationsControllerProvider.notifier);
  return dashCommentsController.getAllNotifications(userID);
});

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, bool>((ref) {
  final _repository = ref.watch(notificationsRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return NotificationsController(
      repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class NotificationsController extends StateNotifier<bool> {
  NotificationsRepository _repository;
  NotificationsController(
      {required NotificationsRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        super(false);

  Future<List<NotificationsModel>> getAllNotifications(String userID) async {
    return _repository.getAllNotifications(userID);
  }
}
