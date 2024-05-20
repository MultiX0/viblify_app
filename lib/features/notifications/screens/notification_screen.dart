// ignore_for_file: unused_result

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/notifications/controller/controller.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:viblify_app/widgets/empty_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/common/follow_button.dart';
import '../../auth/models/user_model.dart';
import '../../user_profile/controller/user_profile_controller.dart';
import '../enums/notifications_enum.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final String userID;
  const NotificationScreen({super.key, required this.userID});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Future<void> _onRefresh(WidgetRef ref) async {
    setState(() {});
    ref.refresh(getNotificationsProvider(widget.userID));
    log("done");
  }

  void goToUserProfile(String uid) {
    context.push("/u/$uid");
  }

  void goToSttScreen() {
    context.push("/stt");
  }

  void goToFeedScreen(String feed_id) {
    context.push("/p/$feed_id");
  }

  void goToDashCommentsScreen(String dash_id, String user_id) {
    context.push("/dash_comments/$dash_id/$user_id");
  }

  @override
  Widget build(BuildContext context) {
    UserModel myData = ref.watch(userProvider)!;

    void updateSeenStatus(int notificationID) async {
      await Supabase.instance.client.rpc("notification_status", params: {"row_id": notificationID});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificatios"),
        centerTitle: true,
      ),
      body: CustomMaterialIndicator(
        onRefresh: () => _onRefresh(ref),
        indicatorBuilder: (context, controller) {
          return const Icon(
            Icons.ac_unit,
            color: Colors.blue,
            size: 30,
          );
        },
        child: ref.watch(getNotificationsProvider(widget.userID)).when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const MyEmptyShowen(text: "No Notifications yet");
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final action = getActionTypeFromString(notification.notification_type);
                        final notification_content = getNotificationString(action);
                        final isUserFollowed =
                            ref.watch(isUserFollowingProvider(notification.userID));
                        final bool isFollowingUser = isUserFollowed.maybeWhen(
                          data: (boolValue) => boolValue, // Use a default value if null
                          orElse: () => false, // Handle other cases (loading, error)
                        );
                        DateTime dateTime = DateTime.parse(notification.createdAt.toString());

                        final createdAt = timeago.format(dateTime, locale: 'en');

                        return ref.watch(getUserDataProvider(notification.userID)).when(
                            data: (user) {
                              if (!notification.seen) {
                                updateSeenStatus(notification.id!);
                              }
                              return ListTile(
                                minTileHeight: 30,
                                onTap: () {
                                  switch (action) {
                                    case ActionType.new_follow:
                                      goToUserProfile(notification.userID);

                                    case ActionType.stt:
                                      goToSttScreen();

                                    case ActionType.feed_like:
                                      goToFeedScreen(notification.feedID);

                                    case ActionType.feed_comment:
                                      goToFeedScreen(notification.feedID);

                                    case ActionType.feed_comment_like:
                                      goToFeedScreen(notification.feedID);

                                    case ActionType.dash_comment:
                                      goToDashCommentsScreen(notification.dashID, myData.userID);

                                    case ActionType.dash_comment_like:
                                      goToDashCommentsScreen(notification.dashID, myData.userID);

                                    default:
                                      null;
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: DenscordColors.scaffoldForeground,
                                  radius: 18,
                                  backgroundImage: CachedNetworkImageProvider(
                                      action == ActionType.stt
                                          ? Constant.userIcon
                                          : user.profilePic),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: action == ActionType.stt
                                                  ? "anonymous"
                                                  : user.name,
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                            const TextSpan(text: " "),
                                            TextSpan(
                                              text: notification_content,
                                              style: TextStyle(color: Colors.grey[500]),
                                            ),
                                            TextSpan(
                                              text: ' ∘ ',
                                              style:
                                                  TextStyle(color: Colors.grey[700], fontSize: 12),
                                            ),
                                            TextSpan(
                                              text: createdAt,
                                              style:
                                                  TextStyle(color: Colors.grey[700], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (action == ActionType.new_follow) ...[
                                      FollowButton(
                                        isFollowingUser: isFollowingUser,
                                        myData: myData,
                                        user: user,
                                      ),
                                    ],
                                    if (!notification.seen) ...[
                                      SizedBox(
                                        width: action == ActionType.new_follow ? 10 : 0,
                                      ),
                                      Icon(
                                        Icons.circle,
                                        color: Colors.blue[900],
                                        size: 10,
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: (action == ActionType.dash_comment ||
                                        action == ActionType.feed_comment)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 5.0),
                                        child: Text(notification.notification),
                                      )
                                    : null,
                              );
                            },
                            error: (error, trace) => ErrorText(error: error.toString()),
                            loading: () => const Loader());
                      },
                    ),
                  );
                }
              },
              error: (error, trace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
