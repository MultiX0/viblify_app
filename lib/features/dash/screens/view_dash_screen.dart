import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';
import 'package:viblify_app/features/dash/widgets/user_card.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/models/dash_model.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

import '../widgets/comments_card.dart';

class DashViewScreen extends ConsumerWidget {
  final Map<String, dynamic> data;

  const DashViewScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myData = ref.read(userProvider)!;
    final dash = Dash.fromMap(data);

    bool isArabic = Bidi.hasAnyRtl(dash.description);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Details"),
        actions: [
          IconButton(
            onPressed: () => more(context, ref, dash.contentUrl, data),
            icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: dash.dashID,
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: MediaQuery.of(context).size.width),
              child: CachedNetworkImage(
                imageUrl: dash.contentUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          UserCard(uid: dash.userID),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              dash.description,
              style: TextStyle(
                color: Colors.grey[400],
              ),
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
          ),
          MyCommentCard(dash: dash, myData: myData),
          DashRecommandations(
            id: dash.dashID,
          ),
        ],
      ),
    );
  }

  void download(WidgetRef ref, String url, BuildContext context) {
    ref.watch(userProfileControllerProvider.notifier).downloadImage(url, context);
    context.pop(context);
  }

  void more(BuildContext context, WidgetRef ref, String url, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("تحميل الصورة"),
              leading: const Icon(Icons.download_rounded),
              onTap: () => download(ref, url, context),
            ),
            ListTile(
              title: const Text("نسخ الرابط"),
              leading: const Icon(Icons.link),
              onTap: () => copyDashUrl(data, context),
            ),
          ],
        );
      },
    );
  }
}

class DashRecommandations extends ConsumerWidget {
  final String id;
  const DashRecommandations({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getDashProvider(id)).when(
          data: (dashs) {
            if (dashs.isNotEmpty) {
              return Wrap(
                children: dashs.map((dash) {
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
                }).toList(),
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
