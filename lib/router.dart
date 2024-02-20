import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/features/Feed/feed_screen.dart';
import 'package:viblify_app/features/Feed/tag_feed_screen.dart';
import 'package:viblify_app/features/auth/screens/login_screen.dart';
import 'package:viblify_app/features/comments/screens/comment_screen.dart';
import 'package:viblify_app/features/community/screens/community_screen.dart';
import 'package:viblify_app/features/community/screens/create_community.dart';
import 'package:viblify_app/features/home/screens/home_screen.dart';
import 'package:viblify_app/features/splash_screen/splash_screen.dart';
import 'package:viblify_app/features/stt/screens/stt_profile_screen.dart';
import 'package:viblify_app/features/stt/screens/stt_screen.dart';
import 'package:viblify_app/features/user_profile/screens/add_post.dart';
import 'package:viblify_app/features/user_profile/screens/edit_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/search_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/video_screen.dart';
import 'package:viblify_app/widgets/feeds_widget.dart';
import 'features/auth/controller/auth_controller.dart';
import 'widgets/profile_pic_widget.dart';

final _key = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authChangeState);

  return GoRouter(
    navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: "/splash",
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeScreen(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: "/",
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: "/search",
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: "/askdjajkjafhaksjdf",
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: "/notifications",
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: "/profile",
                builder: (context, state) => UserProfileScreen(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/splash",
        pageBuilder: (context, state) {
          final user = ref.watch(userProvider.notifier).state;
          if (user == null) {
            return NoTransitionPage(child: SplashScreen());
          }
          return NoTransitionPage(child: const SplashScreen());
        },
      ),
      GoRoute(
        path: "/u/:uid",
        pageBuilder: (context, state) {
          String uid = state.pathParameters['uid']!;
          return NoTransitionPage(child: UserProfileScreen(uid: uid));
        },
      ),
      GoRoute(
        path: "/p/:id",
        pageBuilder: (context, state) {
          String id = state.pathParameters['id']!;
          return NoTransitionPage(child: CommentScreen(feedID: id));
        },
      ),
      GoRoute(
        path: "/video/:id/:title",
        pageBuilder: (context, state) {
          String id = state.pathParameters['id']!;
          String title = state.pathParameters['title']!;
          return NoTransitionPage(
              child: VideoScreen(id: id, nameOfVideo: title));
        },
      ),
      GoRoute(
        path: "/img/slide/:url",
        builder: (context, state) {
          String url = state.pathParameters['url']!;
          return ImageSlidePage(imageUrl: url);
        },
      ),
      GoRoute(
        path: "/stt/page/:uid/:name",
        pageBuilder: (context, state) {
          String uid = state.pathParameters['uid']!;
          String name = state.pathParameters['name']!;
          return NoTransitionPage(
              child: SayTheTruth(userID: uid, useraName: name));
        },
      ),
      GoRoute(
        path: "/tag/:tag",
        pageBuilder: (context, state) {
          String tag = state.pathParameters['tag']!;
          return NoTransitionPage(child: TagFeedsScreen(tag: tag));
        },
      ),
      GoRoute(
        path: "/login",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const LoginScreen());
        },
      ),
      GoRoute(
        path: "/c/create",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const CreateComunityScreen());
        },
      ),
      GoRoute(
        path: "/c/:name",
        pageBuilder: (context, state) {
          String name = state.pathParameters['name']!;
          return NoTransitionPage(child: CommunityScreen(name: name));
        },
      ),
      GoRoute(
        path: "/stt",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const MySttScreen());
        },
      ),
      GoRoute(
        path: "/edit/profile/:uid",
        pageBuilder: (context, state) {
          return NoTransitionPage(
              child: EditProfileScreen(uid: state.pathParameters['uid']!));
        },
      ),
      GoRoute(
        path: "/img/:tag/:url",
        builder: (context, GoRouterState state) {
          final url = state.pathParameters['url']!;
          final link = Uri.decodeComponent(url);
          return ProfileImageScreen(
              tag: state.pathParameters['tag']!, url: link);
        },
      ),
      GoRoute(
        path: "/addpost",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const AddPostScreen());
        },
      ),
      GoRoute(
        path: "/update",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const SizedBox());
        },
      ),
    ],
    redirect: (context, state) {
      // If our async state is loading, don't perform redirects, yet
      if (authState.isLoading || authState.hasError) return null;

      // Here we guarantee that hasData == true, i.e. we have a readable value

      // This has to do with how the FirebaseAuth SDK handles the "log-in" state
      // Returning `null` means "we are not authorized"
      final isAuth = authState.valueOrNull != null;

      final isLoggingIn = state.matchedLocation == "/login";
      // final isSplash = state.matchedLocation == "/splash";
      // if (isSplash) return isAuth ? "/" : "/login";
      if (isLoggingIn) return isAuth ? "/" : null;

      return isAuth ? null : "/login";
    },
  );
});
