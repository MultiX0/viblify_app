import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/stt/screens/stt_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/add_post.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:viblify_app/theme/pallete.dart';

import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _page = 0;

  void onPageChanged(int page) {
    if (page != 2) {
      setState(() {
        _page = page;
      });
    }
    if (page == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const AddPostScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    void navigationToUserProfile(BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => UserProfileScreen(
                uid: user.userID,
              )));
    }

    return Scaffold(
      drawer: const CommunityListDrawer(),
      appBar: _page == 0
          ? AppBar(
              title: Text(
                "Viblify",
              ),
              centerTitle: false,
              forceMaterialTransparency: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MySttScreen()));
                  },
                  icon: const Icon(
                    LineIcons.stickyNote,
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    LineIcons.facebookMessenger,
                    size: 22,
                  ),
                ),
              ],
              bottom: _page == 0
                  ? TabBar(
                      labelColor: Colors.white,
                      dividerColor: Colors.grey.shade900,
                      indicatorColor: Colors.blue,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'For you'),
                        Tab(text: 'Following'),
                      ],
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        child: Constant.navBar(
          uid: user.userID,
        )[_page],
      ),
      bottomNavigationBar: CupertinoTabBar(
        height: kToolbarHeight + 5,
        border: Border(
          top: BorderSide(color: Colors.grey.shade900),
        ),
        activeColor: Colors.white,
        backgroundColor: Pallete.blackColor,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.home,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.search,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.add,
              ),
              label: ''),
          const BottomNavigationBarItem(
              icon: Icon(
                size: 24,
                Ionicons.notifications,
              ),
              label: ''),
          BottomNavigationBarItem(
              activeIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(user.profilePic),
                ),
              ),
              icon: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(user.profilePic),
              ),
              label: ''),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}
