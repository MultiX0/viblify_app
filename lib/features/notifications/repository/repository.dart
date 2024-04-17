// ignore_for_file: void_checks

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/features/notifications/models/notifications_model.dart';

import '../../../core/Constant/firebase_constant.dart';

final notificationsRepositoryProvider = Provider((ref) {
  return NotificationsRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class NotificationsRepository {
  final supabase = Supabase.instance.client;
  NotificationsRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _notification => supabase.from(FirebaseConstant.notificationsCollection);

  Future<List<NotificationsModel>> getAllNotifications(String uid) async {
    try {
      final data =
          await _notification.select('*').eq("to_userID", uid).order("createdAt", ascending: false);

      final List<NotificationsModel> notifications =
          data.map<NotificationsModel>((data) => NotificationsModel.fromMap(data)).toList();

      return notifications;
    } catch (error) {
      log(error.toString());

      Failure("Error getting dashes: $error");
      rethrow;
    }
  }

  Stream<int> getUnSeenNotificationCount(String uid) {
    var ref = _notification.stream(primaryKey: ['notificationID']).eq("to_userID", uid);

    return ref.map(
      (data) {
        int counter = 0;
        if (data.isNotEmpty) {
          for (var doc in data) {
            bool seen = doc['seen'];
            if (seen != true) {
              counter++;
            }
          }
        }
        return counter;
      },
    );
  }
}
