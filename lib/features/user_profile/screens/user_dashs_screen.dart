// ignore_for_file: use_build_context_synchronously, unused_result

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';
import 'package:viblify_app/features/dash/comments/models/dash_model.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

import '../../../core/utils.dart';
import '../../../router.dart';
import '../../auth/controller/auth_controller.dart';

class UserDashScreen extends ConsumerStatefulWidget {
  final String userID;
  const UserDashScreen({super.key, required this.userID});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserDashScreenState();
}

class _UserDashScreenState extends ConsumerState<UserDashScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  String? path;

  void imagePicker() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        path = result.files.first.path!;
      });
      final map = {"path": path};

      context.pushNamed(
        Navigation.addDash,
        extra: map,
      );
      setState(() {
        path = null;
      });
    }
  }

  void _onRefresh(WidgetRef ref) async {
    setState(() {});
    ref.refresh(getAllDashesProvider);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final myData = ref.read(userProvider)!;
    bool isMe = widget.userID == myData.userID;

    return Scaffold(
      floatingActionButton: isMe
          ? FloatingActionButton(
              elevation: 10,
              mini: true,
              onPressed: imagePicker,
              backgroundColor: Pallete.blackColor.withRed(15),
              child: const Icon(Icons.add),
            )
          : null,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () => _onRefresh(ref),
        child: ref.watch(getUserDashesProvider(widget.userID)).when(
              data: (dashs) {
                return dashs.isNotEmpty
                    ? MasonryGridView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        itemCount: dashs.length,
                        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          final dash = dashs[index];

                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Hero(
                              tag: dash.dashID,
                              child: GestureDetector(
                                onTap: () => navigateToDashView(
                                  dash,
                                  myData.userID,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: dash.contentUrl,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : const MyEmptyShowen(text: "لايوجد محتوى بعد");
              },
              error: (error, trace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ),
      ),
    );
  }

  void navigateToDashView(Dash dash, String uid) {
    ref.read(dashControllerProvider.notifier).addUserToViews(dash.dashID, uid);
    context.pushNamed(
      Navigation.dashview,
      extra: dash.toMap(),
    );
  }
}
