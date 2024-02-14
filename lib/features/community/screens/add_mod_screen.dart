import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/community/controller/community_controller.dart';

class AddModScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModScreen> {
  Set<String> uids = {};
  int ctr = 0;
  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void save(String communityName, BuildContext context) {
    ref
        .read(communitControllerProvider.notifier)
        .addMods(communityName, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add mods page"),
        actions: [
          IconButton(
            onPressed: () => save(widget.name, context),
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            return ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, index) {
                final members = community.members[index];
                return ref.watch(getUserDataProvider(members)).when(
                    data: (user) {
                      if (community.mods.contains(members) && ctr == 0) {
                        uids.add(members);
                      }
                      ctr++;
                      return CheckboxListTile(
                        value: uids.contains(user.userID),
                        onChanged: (val) {
                          if (val == true) {
                            addUid(user.userID);
                          } else {
                            removeUid(user.userID);
                          }
                        },
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(user.name),
                          ],
                        ),
                      );
                    },
                    error: (error, trace) => ErrorText(error: error.toString()),
                    loading: () => const Loader());
              },
            );
          },
          error: (error, trace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
