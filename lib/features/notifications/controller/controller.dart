// ignore_for_file: unused_result

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/features/notifications/repository/repository.dart';
import 'package:viblify_app/features/notifications/models/notifications_model.dart';

import '../../../../core/providers/storage_repository_provider.dart';

final getNotificationsProvider = FutureProvider.family((ref, String userID) async {
  final notificationsController = ref.watch(notificationsControllerProvider.notifier);
  return notificationsController.getAllNotifications(userID);
});

final getUnSeenNotificationsProvider = StreamProvider.family((ref, String uid) {
  final notificationsController = ref.watch(notificationsControllerProvider.notifier);

  return notificationsController.getUnSeenNotificationCount(uid);
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

  Stream<int> getUnSeenNotificationCount(String uid) {
    return _repository.getUnSeenNotificationCount(uid);
  }
}
