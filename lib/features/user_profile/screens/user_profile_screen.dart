// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:line_icons/line_icons.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/chats/controller/chats_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/features/user_profile/screens/user_dashs_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_feeds.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/utils/colors.dart';

import 'user_liked_feeds.dart';
import 'user_media_screen.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String myID = ref.watch(userProvider)!.userID;
    UserModel myData = ref.watch(userProvider)!;
    bool isLoading = ref.watch(userProfileControllerProvider);

    void navigationToEditScreen(BuildContext context) {
      context.push(
        "/edit/profile/${widget.uid}",
      );
    }

    void more(String userID) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('نسخ رابط الملف الشخصي'),
                  onTap: () => copyProfileUrl(userID, context),
                ),
              ],
            );
          });
    }

    createRoute(String tag, String photoUrl) {
      String encodedUrl = base64UrlEncode(utf8.encode(photoUrl));

      GoRouter.of(context).push('/img/$tag/$encodedUrl');
    }

    final visitorsID = ref.watch(userProvider)!.userID;
    void toggleFollow() {
      ref.watch(userProfileControllerProvider.notifier).toggleFollow(visitorsID, widget.uid);
    }

    final isUserFollowed = ref.watch(isUserFollowingProvider(widget.uid));
    final bool isFollowingUser = isUserFollowed.maybeWhen(
      data: (boolValue) => boolValue, // Use a default value if null
      orElse: () => false, // Handle other cases (loading, error)
    );

    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: (user.verified && user.profileTheme.isNotEmpty)
                ? HexColor(user.profileTheme)
                : DenscordColors.scaffoldBackground,
            body: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: ((context, innerBoxIsScrolled) {
                  String date = DateFormat('MMMM/d/y').format(user.joinedAt);
                  String websiteName = extractWebsiteName(user.link);

                  void navigationToSTT(BuildContext context) {
                    context.push("/stt/page/${widget.uid}/${user.userName}");
                  }

                  void chats() {
                    ref.read(chatsControllerProvider.notifier).getChatRoom(myData, user, context);
                  }

                  return [
                    ProfileHeader(visitorsID, user, context, more, createRoute, isFollowingUser,
                        chats, isLoading, toggleFollow, myData, navigationToEditScreen),
                    ProfileBody(user, date, myID, websiteName, navigationToSTT, context),
                  ];
                }),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    UserFeedsScreen(
                      uid: widget.uid,
                      isThemeDark: user.isThemeDark,
                      dividerColor: user.dividerColor,
                    ),
                    UserMediaFeeds(
                      uid: widget.uid,
                      isThemeDark: user.isThemeDark,
                      dividerColor: user.dividerColor,
                    ),
                    UserDashScreen(userID: widget.uid),
                    UserLikedFeeds(
                      uid: widget.uid,
                      isThemeDark: user.isThemeDark,
                      dividerColor: user.dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          error: (error, trace) {
            log(
              error.toString(),
            );
            return const Center(
              child: Text("المستخدم الذي تبحث عنه غير موجود"),
            );
          },
          loading: () => const Loader(),
        );
  }

  SliverPadding ProfileBody(UserModel user, String date, String myID, String websiteName,
      void Function(BuildContext context) navigationToSTT, BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.verified) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: user.isThemeDark ? Colors.white : Colors.black),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.verified,
                              color: user.isThemeDark ? Colors.blue : Colors.black,
                              size: 14,
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          user.name,
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: user.isThemeDark ? Colors.white : Colors.black),
                        ),
                      ],
                      Text(
                        "@${user.userName}",
                        style: TextStyle(
                            fontSize: 14,
                            color: user.isThemeDark ? Colors.grey.shade600 : Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              user.bio,
              style: TextStyle(
                  fontSize: user.bio.isEmpty ? 0 : 13,
                  color: user.isThemeDark ? Colors.white : Colors.black,
                  fontWeight: user.isThemeDark ? null : FontWeight.bold),
            ),
            user.bio.isEmpty
                ? const SizedBox()
                : const SizedBox(
                    height: 10,
                  ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: user.location.isEmpty ? 0 : 5),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.grey.shade700,
                    size: user.location.isEmpty ? 0 : 15,
                  ),
                ),
                Text(
                  user.location,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: user.location.isEmpty ? 0 : 15,
                      fontWeight: FontWeight.bold),
                ),
                user.location.isNotEmpty
                    ? const SizedBox(
                        width: 15,
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.grey.shade700,
                    size: 15,
                  ),
                ),
                Text(
                  "Joined $date",
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: user.stt != false && user.userID != myID ? 10 : 0,
            ),
            if (user.link.isNotEmpty) ...[
              const SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      LineIcons.link,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => launchURL(user.link),
                    child: Text(
                      websiteName,
                      style: const TextStyle(
                          color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
            user.link.isEmpty || user.location.isEmpty
                ? const SizedBox()
                : SizedBox(
                    height: user.stt != false && user.userID != myID
                        ? 3
                        : user.mbti.isNotEmpty
                            ? 3
                            : 10,
                  ),
            if (user.stt != false && user.userID != myID) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      LineIcons.stickyNote,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => navigationToSTT(context),
                    child: const Text(
                      'viblify/stt',
                      style:
                          TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: user.mbti.isNotEmpty ? 5 : 10,
              ),
            ],
            if (user.mbti.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      LineIcons.star,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
                  ),
                  Text(
                    user.mbti,
                    style: const TextStyle(
                        color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.push("/following/${user.userID}"),
                  child: RichText(
                    text: TextSpan(
                      text: user.following.length.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.isThemeDark ? Colors.white : Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "  Following",
                          style: TextStyle(color: Colors.grey.shade700),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () => context.push("/followers/${user.userID}"),
                  child: RichText(
                    text: TextSpan(
                      text: user.followers.length.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.isThemeDark ? Colors.white : Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "  Followers",
                          style: TextStyle(color: Colors.grey.shade700),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TabBar(
                labelColor: Colors.white,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.blue,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Media'),
                  Tab(text: 'Dashs'),
                  Tab(text: 'Liked'),
                ],
              ),
            ),
            Divider(
              color: (user.verified &&
                      user.dividerColor.isNotEmpty &&
                      user.profileTheme != getTheHex(Pallete.blackColor.toString()))
                  ? HexColor(user.dividerColor)
                  : Colors.grey[900],
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar ProfileHeader(
      String visitorsID,
      UserModel user,
      BuildContext context,
      void Function(String userID) more,
      Null Function(String tag, String photoUrl) createRoute,
      bool isFollowingUser,
      void Function() chats,
      bool isLoading,
      void Function() toggleFollow,
      UserModel myData,
      void Function(BuildContext context) navigationToEditScreen) {
    return SliverAppBar(
      forceMaterialTransparency: true,
      leading: visitorsID != user.userID
          ? IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HexColor(user.profileTheme),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: user.isThemeDark ? Colors.white : Colors.black,
                    size: 18,
                  ),
                ),
              ),
            )
          : null,
      actions: [
        if (visitorsID == user.userID) ...[
          if (user.verified)
            IconButton(
              onPressed: () => pickColor(user, ref, user.userID),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HexColor(user.profileTheme),
                ),
                child: Center(
                  child: Icon(
                    Icons.color_lens,
                    color: user.isThemeDark ? Colors.white : Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: signout,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexColor(user.profileTheme),
              ),
              child: Center(
                child: Icon(
                  Icons.logout,
                  color: user.isThemeDark ? Colors.white : Colors.black,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
        IconButton(
          onPressed: () => more(user.userID),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HexColor(user.profileTheme),
            ),
            child: Center(
              child: Icon(
                Icons.more_vert,
                color: user.isThemeDark ? Colors.white : Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
      ],
      pinned: false,
      snap: false,
      floating: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              child: Hero(
                tag: "banner_${user.userID}",
                child: GestureDetector(
                  onTap: () => createRoute("banner_${user.userID}", user.bannerPic),
                  child: ExtendedImage.network(
                    user.bannerPic,
                    enableLoadState: false,
                    height: 150,
                    width: double.infinity,
                    cache: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 13,
              left: 10,
              child: Hero(
                tag: "pic_${user.userID}",
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (user.verified && user.profileTheme.isNotEmpty)
                          ? HexColor(user.profileTheme)
                          : Pallete.blackColor,
                      width: 3.5,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => createRoute("pic_${user.userID}", user.profilePic),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.profilePic),
                      radius: 35,
                    ),
                  ),
                ),
              ),
            ),
            if (visitorsID != user.userID) ...[
              if (isFollowingUser) ...[
                if (user.isUserOnline) ...[
                  Positioned(
                    bottom: 13,
                    left: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (user.verified && user.profileTheme.isNotEmpty)
                              ? HexColor(user.profileTheme)
                              : Pallete.blackColor,
                          width: 3.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        radius: 7,
                      ),
                    ),
                  ),
                ],
              ],
            ],
            if (widget.uid != visitorsID)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isFollowingUser) ...[
                        GestureDetector(
                          onTap: chats,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: user.isThemeDark ? Colors.white : Colors.black)),
                            child: Icon(
                              LineIcons.facebookMessenger,
                              color: user.isThemeDark ? Colors.white : Colors.black,
                              size: 19,
                            ),
                          ),
                        ),
                      ],
                      OutlinedButton(
                        onPressed: isLoading ? null : toggleFollow,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.2, 30),

                          side: BorderSide(
                            color: isFollowingUser
                                ? user.isThemeDark
                                    ? Colors.white
                                    : Colors.black
                                : user.isThemeDark
                                    ? Colors.blue
                                    : Colors.black, // Set the border color
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15.0), // Adjust the border radius as needed
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0), // Adjust the padding as needed
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: isFollowingUser
                                      ? user.isThemeDark
                                          ? Colors.white
                                          : Colors.black
                                      : user.isThemeDark
                                          ? Colors.blue
                                          : Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isFollowingUser
                                    ? "unfollow"
                                    : myData.followers.contains(user.userID)
                                        ? "follow back"
                                        : "follow",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isFollowingUser
                                        ? user.isThemeDark
                                            ? Colors.white
                                            : Colors.black
                                        : user.isThemeDark
                                            ? Colors.blue
                                            : Colors.black),
                              ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => navigationToEditScreen(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: user.isThemeDark ? Colors.blue : Colors.black,
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.2, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15.0), // Adjust the border radius as needed
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0), // Adjust the padding as needed
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void pickColor(UserModel user, WidgetRef ref, String uid) {
    List<Map<String, Color>> colorMapList = [
      {'dark': DenscordColors.scaffoldBackground, "divider": Colors.grey.shade900},
      {'dark': const Color(0xff222831), "divider": Colors.grey.shade800},
      {'dark': const Color(0xff191919), "divider": Colors.grey.shade700},
      {'dark': const Color(0xff0F0F0F), "divider": Colors.grey.shade800},
      {'dark': const Color(0xff171717), "divider": Colors.grey.shade800},
      {'dark': const Color(0xff1B262C), "divider": Colors.grey.shade600},
      {'dark': const Color(0xff1E1E24), "divider": Colors.grey.shade800},
      {'light': const Color(0xffC7EFCF), "divider": Colors.black},
    ];

    var color = user.profileTheme;

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Align(
            alignment: Alignment.center,
            child: Text(
              "Pick A Color for Your Profile",
              style: TextStyle(fontSize: 16),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colorMapList
                  .map(
                    (colorMap) => GestureDetector(
                      onTap: () {
                        log("Selected Color: ${colorMap.keys.first}");
                        setState(
                          () => color = getTheHex(
                            ColorToHex(colorMap.values.first).toString(),
                          ),
                        );
                        log(color);
                        ref.read(userProfileControllerProvider.notifier).updateProfileTheme(
                            uid,
                            color,
                            getTheHex(colorMap.values.last.toString()),
                            colorMap.keys.first == "dark" ? true : false);
                        // Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: colorMap.values.first,
                        child: getTheHex(
                                  ColorToHex(colorMap.values.first).toString(),
                                ) ==
                                color
                            ? Center(
                                child: Icon(Icons.done,
                                    color: colorMap.keys.first == "dark"
                                        ? Colors.white
                                        : Colors.black),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  void signout() {
    PanaraConfirmDialog.show(
      context,
      title: "Are you sure?",
      message: "are you sure you want to signout of the application?",
      confirmButtonText: "Confirm",
      cancelButtonText: "Cancel",
      color: Colors.grey.shade900,

      onTapCancel: () {
        context.pop();
      },
      onTapConfirm: () {
        _signOut();
        context.pushReplacement('/login');
        log("logout");
        ref.watch(userProvider.notifier).update((user) => null);
        log("update user data to null");
      },
      panaraDialogType: PanaraDialogType.custom,
      textColor: const Color.fromARGB(255, 22, 17, 17),
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Future<void> _signOut() async {
    try {
      //update the user model data to null;
      ref.watch(userProvider.notifier).update((user) => null);
      //signout with the firebase
      await FirebaseAuth.instance.signOut();
      //close the app
      SystemNavigator.pop(animated: true);
      log('Sign Out Successful');
    } catch (error) {
      log('Error signing out : $error');
      throw Failure(error.toString());
    }
  }
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
