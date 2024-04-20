import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import '../../../core/common/error_text.dart';
import '../controller/story_controller.dart';
import '../screens/story_view_screen.dart';
import '../widget/add_story_tile.dart';
import '../widget/story_tile.dart';

class StoryViewController extends ConsumerWidget {
  const StoryViewController({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.watch(userProvider)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 150,
          child: ref.watch(getAllStoriesProvider).when(
                data: (stories) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: stories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return AddStoryTile(
                          imgUrl: myData.profilePic,
                        );
                      }
                      final story = stories.elementAt(index - 1);
                      return ref.watch(getUserDataProvider(story.userID)).when(
                            data: (user) {
                              return ref.watch(getAllUserStoriesProvider(user.userID)).when(
                                    data: (user_stories) {
                                      return GestureDetector(
                                        onTap: () {
                                          log("user stories length :${user_stories.length}");
                                          if (user_stories.isNotEmpty) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => StoryViewScreen(
                                                  myID: myData.userID,
                                                  stories: user_stories,
                                                ),
                                              ),
                                            );
                                            // context.pushNamed(Navigation.story_view, pathParameters: {
                                            //   'stories': userStoriesJson,
                                            //   'myID': myData.userID,
                                            // });
                                          }
                                        },
                                        child: StoryTile(
                                          story: story,
                                          myData: myData,
                                          story_author: user,
                                        ),
                                      );
                                    },
                                    error: (error, trace) => ErrorText(error: error.toString()),
                                    loading: () {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade900,
                                            highlightColor: Colors.grey.shade800,
                                            child: Container(
                                              color: Colors.white,
                                              height: 150,
                                              width: 80,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                            },
                            error: (error, trace) => ErrorText(error: error.toString()),
                            loading: () {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade900,
                                    highlightColor: Colors.grey.shade800,
                                    child: Container(
                                      color: Colors.white,
                                      height: 150,
                                      width: 80,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                    },
                  );
                },
                error: (error, trace) => ErrorText(error: error.toString()),
                loading: () => ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade900,
                          highlightColor: Colors.grey.shade800,
                          child: Container(
                            color: Colors.white,
                            height: 150,
                            width: 80,
                          ),
                        ),
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
