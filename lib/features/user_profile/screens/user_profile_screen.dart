// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/features/user_profile/screens/edit_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_feeds.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/widgets/profile_pic_widget.dart';

import '../../../core/common/error_text.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(userProfileControllerProvider);

    void navigationToEditScreen(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => EditProfileScreen(
                uid: widget.uid,
              )),
        ),
      );
    }

    _createRoute(String tag, String photoUrl) {
      String encodedUrl = Uri.encodeComponent(photoUrl);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) =>
              ProfileImageScreen(uid: widget.uid, tag: tag, url: encodedUrl)),
        ),
      );
    }

    final visitorsID = ref.watch(userProvider)!.userID;
    void toggleFollow() {
      ref
          .watch(userProfileControllerProvider.notifier)
          .toggleFollow(visitorsID, widget.uid);
    }

    final isUserFollowed = ref.watch(isUserFollowingProvider(widget.uid));
    final bool isFollowingUser = isUserFollowed.maybeWhen(
      data: (boolValue) => boolValue, // Use a default value if null
      orElse: () => false, // Handle other cases (loading, error)
    );

    return Scaffold(
      body: ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => NestedScrollView(
                headerSliverBuilder: ((context, innerBoxIsScrolled) {
                  String date = DateFormat('MMMM/d/y').format(user.joinedAt);
                  String websiteName = extractWebsiteName(user.link);

                  return [
                    SliverAppBar(
                      forceMaterialTransparency: true,
                      leading: visitorsID != user.userID
                          ? IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade900),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 18,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      actions: [
                        if (visitorsID != user.userID) ...[
                          IconButton(
                            onPressed: () {},
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade900),
                              child: const Center(
                                child: Icon(
                                  Icons.more_vert,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        ] else ...[
                          IconButton(
                            onPressed: signout,
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade900),
                              child: const Center(
                                child: Icon(
                                  Icons.logout,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        ]
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
                                tag: "pic",
                                child: GestureDetector(
                                  onTap: () =>
                                      _createRoute("pic", user.bannerPic),
                                  child: Image.network(
                                    user.bannerPic,
                                    height: 150,
                                    width: double.infinity,
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
                                      color: Pallete.blackColor,
                                      width: 3.5,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _createRoute(
                                        "pic_${user.userID}", user.profilePic),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.uid != visitorsID)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isFollowingUser) ...[
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white)),
                                          child: const Icon(
                                            LineIcons.facebookMessenger,
                                            color: Colors.white,
                                            size: 19,
                                          ),
                                        ),
                                      ],
                                      OutlinedButton(
                                        onPressed:
                                            isLoading ? null : toggleFollow,
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              30),

                                          side: BorderSide(
                                            color: isFollowingUser
                                                ? Colors.white
                                                : Colors
                                                    .blue, // Set the border color
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15.0), // Adjust the border radius as needed
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical:
                                                  0), // Adjust the padding as needed
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                width: 15,
                                                height: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: isFollowingUser
                                                      ? Colors.white
                                                      : Colors.blue,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                isFollowingUser
                                                    ? "unfollow"
                                                    : "follow",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: isFollowingUser
                                                        ? Colors.white
                                                        : Colors.blue),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        navigationToEditScreen(context),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                          30),
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Adjust the border radius as needed
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical:
                                              0), // Adjust the padding as needed
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
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (user.verified) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                              size: 14,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                      Text(
                                        "@${user.userName}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
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
                                  fontSize: user.bio.isEmpty ? 0 : 13),
                            ),
                            user.bio.isEmpty
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: user.location.isEmpty ? 0 : 5),
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
                                      color: Colors.grey.shade700,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
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
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            ],
                            user.link.isEmpty || user.location.isEmpty
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: user.following.length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: "  Following",
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: user.followers.length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: "  Followers",
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ),
                  ];
                }),
                body: UserFeedsScreen(
                  uid: widget.uid,
                ),
              ),
          error: (error, trace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
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
        Navigator.pop(context);
      },
      onTapConfirm: () {
        print("object");
        _signOutWithGoogle();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.custom,
      textColor: Colors.grey.shade900,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Future<void> _signOutWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      print('Google Sign Out Successful');
    } catch (error) {
      print('Error signing out with Google: $error');
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
