import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/story_view.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/story/controller/story_controller.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../models/story_model.dart';
import '../widget/StoryInfoTile.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({
    Key? key,
    required this.stories,
    required this.myID,
  }) : super(key: key);

  final List<Story> stories;
  final String myID;

  static const routeName = '/story-view';

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final controller = StoryController();

  final List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    for (final story in widget.stories) {
      final storyView = StoryItem(
        StoryDetailScreen(
          story: story,
          myID: widget.myID,
        ),
        duration: const Duration(seconds: 5),
      );
      storyItems.add(storyView);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoryView(
      indicatorOuterPadding: const EdgeInsets.all(8),
      storyItems: storyItems,
      controller: controller,
      indicatorColor: Colors.grey[700],
      indicatorHeight: IndicatorHeight.small,
      onComplete: Navigator.of(context).pop,
      onVerticalSwipeComplete: (direction) {
        if (direction == Direction.down) {
          Navigator.pop(context);
        }
      },
    );
  }
}

class StoryDetailScreen extends ConsumerStatefulWidget {
  const StoryDetailScreen({
    super.key,
    required this.story,
    required this.myID,
  });

  final Story story;
  final String myID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DenscordColors.scaffoldForeground,
      body: ref.watch(getUserDataProvider(widget.story.userID)).when(
            data: (user) {
              if (!widget.story.views.contains(widget.myID)) {
                ref
                    .read(storyControllerProvider.notifier)
                    .viewStory(storyID: widget.story.storyID, userID: widget.myID);
              }
              return Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Image(
                        image: CachedNetworkImageProvider(widget.story.content_url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: StoryInfoTile(
                      publish_date: widget.story.createdAt.toString(),
                      user_name: user.name,
                      avatar: user.profilePic,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10,
                  //   left: 0,
                  //   right: 0,
                  //   child: Container(
                  //     width: 100,
                  //     height: 50,
                  //     color: Colors.black54,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const FaIcon(
                  //           FontAwesomeIcons.eye,
                  //           color: AppColors.realWhiteColor,
                  //         ),
                  //         const SizedBox(width: 10),
                  //         Text(
                  //           '${widget.story.views.length}',
                  //           style: const TextStyle(
                  //             color: AppColors.realWhiteColor,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
