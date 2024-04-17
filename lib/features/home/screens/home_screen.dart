// ignore_for_file: unused_result

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/Feed/feed_screen.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/user_profile/repository/update_user_status.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:badges/badges.dart' as badges;
import '../../notifications/controller/controller.dart';
import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  String? userUid;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        log("onMessageOpenedApp");

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          log("onMessageOpenedApp");
          String chatID = message.data['chatid'] ?? "";
          String uid = message.data['uid'] ?? "";
          context.push("/inbox");
          context.push("/chat/$uid/$chatID");
        }
      },
    );
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      userUid = currentUser.uid;
      UpdateUserStatus().updateActiveStatus(true, userUid!);
    }

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (userUid != null) {
      if (state == AppLifecycleState.resumed) {
        UpdateUserStatus().updateActiveStatus(true, userUid!);
      } else if (state == AppLifecycleState.paused) {
        UpdateUserStatus().updateActiveStatus(false, userUid!);
      } else if (state == AppLifecycleState.detached) {
        UpdateUserStatus().updateActiveStatus(false, userUid!);
      } else {
        UpdateUserStatus().updateActiveStatus(false, userUid!);
      }
    }
  }

  int page = 0;

  void onTap(context, int index) {
    setState(() {
      page = index;
    });
    if (page != 2) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
    if (page == 2) {
      GoRouter.of(context).push('/addpost');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return Scaffold(
      drawer: const CommunityListDrawer(),
      appBar: widget.navigationShell.currentIndex == 0
          ? AppBar(
              title: const Text(
                "viblify",
              ),
              centerTitle: false,
              forceMaterialTransparency: true,
              actions: [
                ref.watch(getUnSeenNotificationsProvider(user.userID)).when(
                      data: (data) {
                        return data != 0
                            ? badges.Badge(
                                position: badges.BadgePosition.topEnd(top: 0, end: 5),
                                badgeContent: Text(
                                  data.toString(),
                                  style: const TextStyle(fontFamily: "FixelDisplay"),
                                ),
                                badgeAnimation: const badges.BadgeAnimation.rotation(
                                  animationDuration: Duration(seconds: 1),
                                  colorChangeAnimationDuration: Duration(seconds: 4),
                                  loopAnimation: false,
                                  curve: Curves.fastOutSlowIn,
                                  colorChangeAnimationCurve: Curves.easeInCubic,
                                ),
                                badgeStyle: const badges.BadgeStyle(
                                  padding: EdgeInsets.all(5),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    ref.refresh(getNotificationsProvider(user.userID));
                                    context.push("/notifications/${user.userID}");
                                  },
                                  icon: const Icon(
                                    LineIcons.bell,
                                    size: 22,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  ref.refresh(getNotificationsProvider(user.userID));
                                  context.push("/notifications/${user.userID}");
                                },
                                icon: const Icon(
                                  LineIcons.bell,
                                  size: 22,
                                ),
                              );
                      },
                      error: (error, stackTrace) => ErrorText(error: error.toString()),
                      loading: () => IconButton(
                        onPressed: () {
                          ref.refresh(getNotificationsProvider(user.userID));
                          context.push("/notifications/${user.userID}");
                        },
                        icon: const Icon(
                          LineIcons.bell,
                          size: 22,
                        ),
                      ),
                    ),
                IconButton(
                  onPressed: () => context.push("/stt"),
                  icon: const Icon(
                    LineIcons.stickyNote,
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push("/inbox"),
                  icon: const Icon(
                    LineIcons.facebookMessenger,
                    size: 22,
                  ),
                ),
              ],
              bottom: widget.navigationShell.currentIndex == 0
                  ? TabBar(
                      labelColor: Colors.white,
                      dividerColor: Colors.grey.shade900,
                      indicatorColor: Colors.blue,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'For you'),
                        Tab(text: 'Following'),
                      ],
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        child: widget.navigationShell.currentIndex == 0
            ? TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: const [FeedScreen(), FollowingTimeLine()],
              )
            : widget.navigationShell,
      ),
      bottomNavigationBar: CupertinoTabBar(
        height: kToolbarHeight + 5,
        border: Border(
          top: BorderSide(color: Colors.grey.shade900),
        ),
        activeColor: Colors.white,
        backgroundColor: DenscordColors.scaffoldBackground,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.home,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.search,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.add,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.albums,
              ),
              label: ''),
          BottomNavigationBarItem(
              activeIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: CachedNetworkImageProvider(user.profilePic),
                ),
              ),
              icon: CircleAvatar(
                radius: 14,
                backgroundImage: CachedNetworkImageProvider(user.profilePic),
              ),
              label: ''),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (int index) => onTap(context, index),
      ),
    );
  }
}
