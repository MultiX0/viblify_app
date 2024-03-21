import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/community/controller/community_controller.dart';

import '../../../core/common/error_text.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigationToCreateCommunity(BuildContext context) {
    context.push("/c/create");
  }

  void navigationToCommunity(BuildContext context, String community) {
    context.push("/c/$community");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          ListTile(
            title: const Text("Creating a Community"),
            leading: const Icon(Icons.add),
            onTap: () => navigationToCreateCommunity(context),
          ),
          ref.watch(userCommunitiesProvider).when(
                data: (communities) => Expanded(
                  child: ListView.builder(
                    itemCount: communities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = communities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(community.avatar),
                        ),
                        title: Text(community.name),
                        onTap: () => navigationToCommunity(context, community.name),
                      );
                    },
                  ),
                ),
                error: (error, stackTrace) {
                  log(error.toString());
                  return ErrorText(
                    error: error.toString(),
                  );
                },
                loading: () => const Loader(),
              ),
        ],
      )),
    );
  }
}
