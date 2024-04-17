import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viblify_app/core/common/error_text.dart';

import 'package:viblify_app/features/story/controller/story_controller.dart';

import '../../auth/controller/auth_controller.dart';

class StoryTile extends ConsumerWidget {
  final String userID;
  const StoryTile({super.key, required this.userID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.watch(userProvider)!;
    bool isMe = myData.userID == userID;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: SizedBox(
        height: 150,
        child: ref.watch(getAllStoriesProvider(ref)).when(
              data: (stories) {
                return stories.isEmpty
                    ? null
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return ref.watch(getUserDataProvider(story.userID)).when(
                                data: (user) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 150,
                                        width: 90,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image(
                                                image: CachedNetworkImageProvider(
                                                  story.content_url.isEmpty
                                                      ? user.profilePic
                                                      : story.content_url,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.black.withOpacity(0.15),
                                                    Colors.black.withOpacity(0.65)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.grey.shade800,
                                                            width: 1.5),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor: Colors.grey[900],
                                                        backgroundImage: CachedNetworkImageProvider(
                                                            user.profilePic),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "@${user.userName}",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.grey[200],
                                                          fontSize: 11,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  user.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[300],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                error: (error, trace) => ErrorText(error: error.toString()),
                                loading: () {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
    );
  }
}
