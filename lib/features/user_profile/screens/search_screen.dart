import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../../community/controller/community_controller.dart';
import '../../community/screens/community_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';
  final search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.blackColor,
        elevation: 0,
        title: Row(
          children: [
            const Text("Viblify"),
            const SizedBox(
              width: 25,
            ),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    query = val;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  prefixIconColor: Colors.white,
                  hintText: 'Search Viblify',
                  hintStyle: const TextStyle(
                      color: Colors.white, fontFamily: "LobsterTwo"),
                ),
              ),
            ),
          ],
        ),
      ),
      body: query.isNotEmpty
          ? ref.watch(searchCommunityProvider(query)).when(
                data: (communites) => ListView.builder(
                  itemCount: communites.length,
                  itemBuilder: (BuildContext context, int index) {
                    final community = communites[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(community.avatar),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(community.name),
                          Text(
                            "${community.members.length} Members",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      onTap: () => navigateToCommunity(context, community.name),
                    );
                  },
                ),
                error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
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
                  "no results yet",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
    );
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => CommunityScreen(name: communityName)),
      ),
    );
  }
}
