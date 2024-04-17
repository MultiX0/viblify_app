// ignore_for_file: unused_result

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/features/story/widget/add_story_tile.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';
import 'package:viblify_app/widgets/feeds_widget.dart';

import '../story/widget/story_tile.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  Future<void> _onRefresh(WidgetRef ref) async {
    setState(() {});
    ref.refresh(getAllFeedsProvider(FirebaseAuth.instance.currentUser!.uid));
    log("done");
  }

  @override
  Widget build(BuildContext context) {
    final myData = ref.watch(userProvider)!;
    final uid = ref.watch(userProvider)!.userID;
    return Scaffold(
      body: CustomMaterialIndicator(
        onRefresh: () => _onRefresh(ref),
        indicatorBuilder: (context, controller) {
          return const Icon(
            Icons.ac_unit,
            color: Colors.blue,
            size: 30,
          );
        },
        child: ref.read(getAllFeedsProvider(uid)).when(
              data: (posts) => posts.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (uid.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                AddStoryTile(imgUrl: myData.profilePic),
                                StoryTile(
                                  userID: uid,
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(),
                        Expanded(
                          child: FeedsWidget(
                              isUserProfile: false,
                              posts: posts,
                              isThemeDark: true,
                              dividerColor: ""),
                        ),
                      ],
                    )
                  : const Center(
                      child: MyEmptyShowen(text: "ليست هنالك أي مناشير بعد"),
                    ),
              error: (error, trace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text('Item number $index as title'),
                        subtitle: const Text('Subtitle here'),
                        leading: const Icon(Icons.ac_unit),
                      ),
                    );
                  },
                ),
              ),
            ),
      ),
    );
  }
}

class FollowingTimeLine extends ConsumerWidget {
  const FollowingTimeLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(userProvider)!.userID;

    return ref.watch(getFollowingProvider(uid)).when(
          data: (users) {
            return ref.watch(getFollowingFeedsProvider(users)).when(
                  data: (data) {
                    return FeedsWidget(
                      isUserProfile: false,
                      posts: data,
                      isThemeDark: true,
                      dividerColor: "",
                    );
                  },
                  error: (error, trace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('Item number $index as title'),
                            subtitle: const Text('Subtitle here'),
                            leading: const Icon(Icons.ac_unit),
                          ),
                        );
                      },
                    ),
                  ),
                );
          },
          error: (error, trace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Item number $index as title'),
                    subtitle: const Text('Subtitle here'),
                    leading: const Icon(Icons.ac_unit),
                  ),
                );
              },
            ),
          ),
        );
  }
}
