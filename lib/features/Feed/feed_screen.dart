import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';
import 'package:viblify_app/widgets/feeds_widget.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(userProvider)!.userID;
    return ref.watch(getAllFeedsProvider(uid)).when(
          data: (posts) => posts.isNotEmpty
              ? FeedsWidget(posts: posts)
              : const Center(
                  child: MyEmptyShowen(text: "ليست هنالك أي مناشير بعد")),
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
