import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';
import 'package:viblify_app/router.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

import '../comments/models/dash_model.dart';

class DashRecommandations extends ConsumerWidget {
  final String id;

  final List<dynamic> labels;
  const DashRecommandations({super.key, required this.id, required this.labels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.read(userProvider)!;
    void navigateToDashView(Dash dash, String uid) {
      ref.read(dashControllerProvider.notifier).addUserToViews(dash.dashID, uid);
      context.pushNamed(
        Navigation.dashview,
        extra: dash.toMap(),
      );
    }

    return ref.watch(getRecommendedDashProvider(Tuple2(id, labels))).when(
          data: (dashs) {
            if (dashs.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "You may also like :",
                      style: TextStyle(
                          color: Colors.grey[400], fontFamily: "FixelDisplay", fontSize: 16),
                    ),
                  ),
                  MasonryGridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      itemCount: dashs.length,
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        final dash = dashs[index];

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Hero(
                            tag: dash.dashID,
                            child: GestureDetector(
                              onTap: () => navigateToDashView(dash, myData.userID),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: dash.contentUrl,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ],
              );
            } else {
              return const MyEmptyShowen(text: "لايوجد محتوى بعد");
            }
          },
          error: (error, trace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
