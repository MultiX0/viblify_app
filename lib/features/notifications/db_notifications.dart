// ignore_for_file: constant_identifier_names

import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';

import 'models/notifications_model.dart';
import 'enums/notifications_enum.dart';

class DbNotifications {
  final supabase = Supabase.instance.client;
  final String? feedID;
  final String? sttID;
  final String userID;
  final String to_userID;
  final String? dashID;
  final ActionType notification_type;

  final String? notification_content;
  DbNotifications(
      {required this.userID,
      this.feedID,
      this.sttID,
      required this.to_userID,
      this.dashID,
      this.notification_content,
      required this.notification_type});
  void addNotification() async {
    try {
      // Construct the notification object
      final notification = NotificationsModel(
        dashID: dashID ?? "",
        to_userID: to_userID,
        seen: false,
        userID: userID,
        feedID: feedID ?? "",
        notification_type: getActionTypeString(notification_type),
        notification: notification_content ?? "",
        sttID: sttID ?? "",
      );

      // Check if both feedID and dashID are empty
      if ((feedID == null || feedID!.isEmpty) && (dashID == null || dashID!.isEmpty)) {
        // Add new notification
        await supabase.from(FirebaseConstant.notificationsCollection).insert(notification.toMap());
      } else if (notification_type != ActionType.dash_like ||
          notification_type != ActionType.feed_like) {
        await supabase.from(FirebaseConstant.notificationsCollection).insert(notification.toMap());
      } else if (feedID != null && feedID!.isNotEmpty) {
        // Check if there's a notification for this feedID
        var feedNotification = await supabase
            .from(FirebaseConstant.notificationsCollection)
            .select('*')
            .eq("feedID", feedID!);

        // Check if any notification exists for this feedID
        if (feedNotification.isNotEmpty) {
          // Check if the userID matches the userID in the row
          var userNotification = feedNotification.firstWhere(
            (row) => row['userID'] == userID,
          );
          if (userNotification.isNotEmpty) {
            // Print something if userID matches
            print("User already has a notification for this feedID");
          } else {
            // Add new notification if userID does not match
            await supabase
                .from(FirebaseConstant.notificationsCollection)
                .insert(notification.toMap());
          }
        } else {
          // Add new notification if no notification exists for this feedID
          await supabase
              .from(FirebaseConstant.notificationsCollection)
              .insert(notification.toMap());
        }
      }

      // Check if dashID is not empty
      if (dashID != null && dashID!.isNotEmpty) {
        // Check if there's a notification for this dashID
        var dashNotification = await supabase
            .from(FirebaseConstant.notificationsCollection)
            .select('*')
            .eq("dashID", dashID!);

        // Check if any notification exists for this dashID
        if (dashNotification.isNotEmpty) {
          // Check if the userID matches the userID in the row
          var userNotification = dashNotification.firstWhere(
            (row) => row['userID'] == userID,
          );
          if (userNotification.isNotEmpty) {
            // Print something if userID matches
            print("User already has a notification for this dashID");
          } else {
            // Add new notification if userID does not match
            await supabase
                .from(FirebaseConstant.notificationsCollection)
                .insert(notification.toMap());
          }
        } else {
          // Add new notification if no notification exists for this dashID
          await supabase
              .from(FirebaseConstant.notificationsCollection)
              .insert(notification.toMap());
        }
      }
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }
}
