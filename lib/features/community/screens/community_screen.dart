// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/community/models/community_model.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

import '../controller/community_controller.dart';
import 'mod_tools_screen.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({
    required this.name,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
      ref.read(communitControllerProvider.notifier).joinCommunity(community, context);
    }

    void navigationToSettings(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => ModToolScreen(
                name: name,
              )),
        ),
      );
    }

    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
          data: (community) => NestedScrollView(
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    expandedHeight: 150,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image(
                            image: CachedNetworkImageProvider(community.banner),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(community.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  community.name,
                                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                ),
                              ),
                              community.mods.contains(user.userID)
                                  ? OutlinedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 25)),
                                      onPressed: () => navigationToSettings(context),
                                      child: const Text("settings"))
                                  : OutlinedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 25)),
                                      onPressed: () => joinCommunity(ref, community, context),
                                      child: Text(community.members.contains(user.userID)
                                          ? "leave"
                                          : "Join")),
                            ],
                          ),
                          Text("${community.members.length} members"),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ];
              }),
              body: const MyEmptyShowen(
                text: 'Soon',
              )),
          error: (error, trace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
