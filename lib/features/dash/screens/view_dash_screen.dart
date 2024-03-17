import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/features/dash/widgets/user_card.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/models/dash_model.dart';

class DashViewScreen extends ConsumerWidget {
  final Map<String, dynamic> data;

  const DashViewScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = Dash.fromMap(data);

    bool isArabic = Bidi.hasAnyRtl(dash.description);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Details"),
        actions: [
          IconButton(
            onPressed: () => more(context, ref, dash.contentUrl),
            icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: dash.dashID,
            child: CachedNetworkImage(imageUrl: dash.contentUrl),
          ),
          UserCard(uid: dash.userID),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              dash.description,
              style: TextStyle(
                color: Colors.grey[300],
              ),
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  void download(WidgetRef ref, String url, BuildContext context) {
    ref.watch(userProfileControllerProvider.notifier).downloadImage(url, context);
    context.pop(context);
  }

  void more(BuildContext context, WidgetRef ref, String url) {
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
            )
          ],
        );
      },
    );
  }
}