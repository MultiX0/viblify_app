import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  final String query;
  const UserSearchScreen({super.key, required this.query});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<UserSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.query.isNotEmpty
            ? ref.watch(searchUsersProvider(widget.query)).when(
                  data: (users) => ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(user.profilePic),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name),
                            Text(
                              "@${user.userName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        onTap: () => navigateToUserScreen(context, user.userID),
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

  void navigateToUserScreen(BuildContext context, String uid) {
    context.push("/u/$uid");
  }
}
