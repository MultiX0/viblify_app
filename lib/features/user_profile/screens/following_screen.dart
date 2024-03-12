import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';

void goToUserScreen(String userID, BuildContext context) {
  context.push("/u/$userID");
}

class FollowingScreen extends ConsumerWidget {
  final String userID;
  const FollowingScreen({super.key, required this.userID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
      ),
      body: ref.watch(getFollowingProvider(userID)).when(
            data: (users) {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ref.read(getUserDataProvider(user.toString())).when(
                        data: (data) {
                          final isFollowing =
                              myData.following.contains(data.userID);
                          void toggleFollow() {
                            ref
                                .watch(userProfileControllerProvider.notifier)
                                .toggleFollow(myData.userID, data.userID);
                          }

                          if ((myData.userID == data.userID) &&
                              (userID == myData.userID)) {
                            return const SizedBox();
                          } else {
                            return data.userID == myData.userID
                                ? const SizedBox()
                                : Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  data.profilePic),
                                          radius: 35,
                                        ),
                                        onTap: () => goToUserScreen(
                                            data.userID, context),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.name,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "@${data.userName}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: toggleFollow,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: isFollowing
                                                          ? Colors.white
                                                          : Colors.blue),
                                                ),
                                                child: Text(
                                                  isFollowing
                                                      ? "الغاء المتابعة"
                                                      : "تابع",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Divider(
                                          color: Colors.grey[900],
                                        ),
                                      )
                                    ],
                                  );
                          }
                        },
                        error: (error, trace) =>
                            ErrorText(error: error.toString()),
                        loading: () => Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[900]!,
                            ),
                            title: const Text("viblify user"),
                            subtitle: const Text("@viblify_username"),
                          ),
                        ),
                      );
                },
              );
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[900]!,
                    ),
                    title: const Text("viblify user"),
                    subtitle: const Text("@viblify_username"),
                  ),
                );
              },
            ),
          ),
    );
  }
}

class FollowersScreen extends ConsumerWidget {
  final String userID;
  const FollowersScreen({super.key, required this.userID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Followers"),
      ),
      body: ref.watch(getFollowersProvider(userID)).when(
            data: (users) {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ref.read(getUserDataProvider(user.toString())).when(
                        data: (data) {
                          final isFollowing =
                              myData.following.contains(data.userID);
                          void toggleFollow() {
                            ref
                                .watch(userProfileControllerProvider.notifier)
                                .toggleFollow(myData.userID, data.userID);
                          }

                          if ((myData.userID == data.userID) &&
                              (userID == myData.userID)) {
                            return const SizedBox();
                          } else {
                            return data.userID == myData.userID
                                ? const SizedBox()
                                : Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  data.profilePic),
                                          radius: 35,
                                        ),
                                        onTap: () => goToUserScreen(
                                            data.userID, context),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.name,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "@${data.userName}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: toggleFollow,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: isFollowing
                                                          ? Colors.white
                                                          : Colors.blue),
                                                ),
                                                child: Text(
                                                  isFollowing
                                                      ? "الغاء المتابعة"
                                                      : "تابع",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Divider(
                                          color: Colors.grey[900],
                                        ),
                                      )
                                    ],
                                  );
                          }
                        },
                        error: (error, trace) =>
                            ErrorText(error: error.toString()),
                        loading: () => Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[900]!,
                            ),
                            title: const Text("viblify user"),
                            subtitle: const Text("@viblify_username"),
                          ),
                        ),
                      );
                },
              );
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[900]!,
                    ),
                    title: const Text("viblify user"),
                    subtitle: const Text("@viblify_username"),
                  ),
                );
              },
            ),
          ),
    );
  }
}
