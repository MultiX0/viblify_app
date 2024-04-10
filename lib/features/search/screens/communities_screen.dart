import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/community/controller/community_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

class CommunitySearchScreen extends ConsumerStatefulWidget {
  final String query;
  const CommunitySearchScreen({super.key, required this.query});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<CommunitySearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.query.isNotEmpty
            ? ref.watch(searchCommunityProvider(widget.query)).when(
                  data: (communities) => ListView.builder(
                    itemCount: communities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = communities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(community.avatar),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(community.name),
                            Text(
                              "${community.members.length} Memerbs",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        onTap: () => navigateToUserScreen(context, community.name),
                      );
                    },
                  ),
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                )
            : const MyEmptyShowen(text: "لاتوجد نتائج"));
  }

  void navigateToUserScreen(BuildContext context, String name) {
    context.push("/c/$name");
  }
}
