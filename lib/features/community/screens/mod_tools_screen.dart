import 'package:flutter/material.dart';
import 'package:viblify_app/features/community/screens/add_mod_screen.dart';
import 'package:viblify_app/features/community/screens/edit_community.dart';
import 'package:viblify_app/responsive/responsive.dart';

class ModToolScreen extends StatelessWidget {
  final String name;
  const ModToolScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    void navigationToEditCommunity(BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => EditCommunityScreen(
                name: name,
              )));
    }

    void navigationToAddModScreen(BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => AddModScreen(
                name: name,
              )));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Settings'),
      ),
      body: Responsive(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add_moderator),
              title: const Text("Add Moderators"),
              onTap: () => navigationToAddModScreen(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Community"),
              onTap: () => navigationToEditCommunity(context),
            ),
          ],
        ),
      ),
    );
  }
}
