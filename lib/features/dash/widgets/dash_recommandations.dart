import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tuple/tuple.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

class DashRecommandations extends ConsumerWidget {
  final String id;
  final List<dynamic> tags;
  final List<dynamic> labels;
  const DashRecommandations({super.key, required this.id, required this.tags, required this.labels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getRecommendedDashProvider(Tuple3(id, labels, tags))).when(
          data: (dashs) {
            if (dashs.isNotEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: MasonryGridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: dashs.length,
                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final dash = dashs[index];

                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Hero(
                          tag: dash.dashID,
                          child: GestureDetector(
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
