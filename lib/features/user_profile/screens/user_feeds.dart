import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';

import '../../../widgets/feeds_widget.dart';

class UserFeedsScreen extends ConsumerWidget {
  final String uid;
  final bool isThemeDark;
  final String dividerColor;
  const UserFeedsScreen(
      {super.key,
      required this.uid,
      required this.isThemeDark,
      required this.dividerColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getUserFeedsProvider(uid)).when(
          data: (posts) => posts.isNotEmpty
              ? FeedsWidget(
                  posts: posts,
                  isThemeDark: isThemeDark,
                  dividerColor: dividerColor,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        Constant.cryPath,
                        height: MediaQuery.of(context).size.width / 2.5,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "no posts yet",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
          error: (error, trace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
