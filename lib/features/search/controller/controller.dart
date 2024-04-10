import 'package:flutter/material.dart';
import 'package:viblify_app/features/search/screens/communities_screen.dart';
import 'package:viblify_app/features/search/screens/users_screen.dart';
import 'package:viblify_app/widgets/empty_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String query = '';

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const Text("viblify"),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20.0),
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
                  hintText: 'Search viblify',
                  hintStyle: const TextStyle(color: Colors.white, fontFamily: "LobsterTwo"),
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          labelColor: Colors.white,
          dividerColor: Colors.grey.shade900,
          indicatorColor: Colors.blue,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Accounts'),
            Tab(text: 'Communities'),
            Tab(text: 'Tags'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            UserSearchScreen(
              query: query,
            ),
            CommunitySearchScreen(
              query: query,
            ),
            const MyEmptyShowen(text: "لاتوجد نتائج"),
          ],
        ),
      ),
    );
  }
}
