// ignore_for_file: constant_identifier_names

import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';

import '../../models/notifications_model.dart';

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

enum ActionType {
  feed_like,
  feed_comment,
  feed_comment_like,
  dash_like,
  dash_comment,
  dash_comment_like,
  stt,
  new_follow,
}

String getActionTypeString(ActionType actionType) {
  switch (actionType) {
    case ActionType.feed_like:
      return 'feed_like';
    case ActionType.feed_comment:
      return 'feed_comment';
    case ActionType.feed_comment_like:
      return 'feed_comment_like';
    case ActionType.dash_like:
      return 'dash_like';
    case ActionType.dash_comment:
      return 'dash_comment';
    case ActionType.dash_comment_like:
      return 'dash_comment_like';
    case ActionType.stt:
      return 'stt';
    case ActionType.new_follow:
      return 'new_follow';
    default:
      return ''; // Handle any other cases if needed
  }
}

ActionType getActionTypeFromString(String actionString) {
  switch (actionString) {
    case 'feed_like':
      return ActionType.feed_like;
    case 'feed_comment':
      return ActionType.feed_comment;
    case 'feed_comment_like':
      return ActionType.feed_comment_like;
    case 'dash_like':
      return ActionType.dash_like;
    case 'dash_comment':
      return ActionType.dash_comment;
    case 'dash_comment_like':
      return ActionType.dash_comment_like;
    case 'stt':
      return ActionType.stt;
    case 'new_follow':
      return ActionType.new_follow;

    default:
      throw ArgumentError('Invalid action string: $actionString');
  }
}

String getNotificationString(ActionType actionType) {
  switch (actionType) {
    case ActionType.feed_like:
      return 'Likes Your Post';
    case ActionType.feed_comment:
      return 'Commented on Your Post';
    case ActionType.feed_comment_like:
      return 'Like Your Comment on the Post';
    case ActionType.dash_like:
      return 'Likes Your Dash';
    case ActionType.dash_comment:
      return 'Commented on Your Dash';
    case ActionType.dash_comment_like:
      return 'Like Your Comment on the Dash';

    case ActionType.stt:
      return 'send new anonymous message';
    case ActionType.new_follow:
      return 'start following you';
    default:
      return '';
  }
}
