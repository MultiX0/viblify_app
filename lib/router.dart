import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:viblify_app/features/Feed/tag_feed_screen.dart';
import 'package:viblify_app/features/auth/screens/login_screen.dart';
import 'package:viblify_app/features/community/screens/add_mod_screen.dart';
import 'package:viblify_app/features/community/screens/community_screen.dart';
import 'package:viblify_app/features/community/screens/create_community.dart';
import 'package:viblify_app/features/community/screens/edit_community.dart';
import 'package:viblify_app/features/community/screens/mod_tools_screen.dart';
import 'package:viblify_app/features/home/screens/home_screen.dart';
import 'package:viblify_app/features/user_profile/screens/add_post.dart';
import 'package:viblify_app/features/user_profile/screens/edit_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/search_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const TransitionPage(
      child: CreateComunityScreen(),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  '/c/:name': (route) => MaterialPage(
        child: CommunityScreen(
          name: route.pathParameters['name']!,
        ),
      ),
  "/community-settings/:name": (router) => TransitionPage(
      child: ModToolScreen(
        name: router.pathParameters['name']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  "/edit-community/:name": (router) => TransitionPage(
      child: EditCommunityScreen(
        name: router.pathParameters['name']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  "/add-mod/:name": (router) => TransitionPage(
      child: AddModScreen(
        name: router.pathParameters['name']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  "/userProfile/:uid": (router) => TransitionPage(
      child: UserProfileScreen(
        uid: router.pathParameters['uid']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.cupertino),
  "/editUser/:uid": (router) => TransitionPage(
      child: EditProfileScreen(
        uid: router.pathParameters['uid']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  "/search-screen": (router) => const MaterialPage(
        child: SearchScreen(),
      ),
  "/add-post": (router) => const TransitionPage(
      child: AddPostScreen(),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
  "/t/:tag": (router) => TransitionPage(
      child: TagFeedsScreen(
        tag: router.pathParameters['tag']!,
      ),
      pushTransition: PageTransition.none,
      popTransition: PageTransition.none),
});
