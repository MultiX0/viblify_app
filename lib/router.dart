import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/features/Feed/feed_screen.dart';
import 'package:viblify_app/features/Feed/tag_feed_screen.dart';
import 'package:viblify_app/features/auth/screens/auth_screen.dart';
import 'package:viblify_app/features/auth/screens/signin_screen.dart';
import 'package:viblify_app/features/chats/screens/chat_screen.dart';
import 'package:viblify_app/features/chats/screens/inbox_screen.dart';
import 'package:viblify_app/features/comments/screens/comment_screen.dart';
import 'package:viblify_app/features/community/screens/community_screen.dart';
import 'package:viblify_app/features/community/screens/create_community.dart';
import 'package:viblify_app/features/dash/screens/dash_add_screen.dart';
import 'package:viblify_app/features/dash/screens/dash_screen.dart';
import 'package:viblify_app/features/home/screens/home_screen.dart';
import 'package:viblify_app/features/splash_screen/splash_screen.dart';
import 'package:viblify_app/features/stt/screens/stt_profile_screen.dart';
import 'package:viblify_app/features/stt/screens/stt_screen.dart';
import 'package:viblify_app/features/user_profile/screens/add_post.dart';
import 'package:viblify_app/features/user_profile/screens/edit_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/following_screen.dart';
import 'package:viblify_app/features/user_profile/screens/search_screen.dart';
import 'package:viblify_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:viblify_app/features/user_profile/screens/video_screen.dart';
import 'package:viblify_app/widgets/image_slide.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/screens/registeration_screen.dart';
import 'features/dash/screens/view_dash_screen.dart';
import 'widgets/profile_pic_widget.dart';

class Navigation {
  Navigation._();

  static const addDash = "newDash";
  static const dashview = "dashview";
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final routerProvider = Provider<GoRouter>((ref) {
  //final authState = ref.watch(authChangeState);

  return GoRouter(
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    navigatorKey: navigatorKey,
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
                path: "/dash",
                builder: (context, state) => const DashScreen(),
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
            return const NoTransitionPage(child: SplashScreen());
          }
          return const NoTransitionPage(child: SplashScreen());
        },
      ),
      GoRoute(
        path: "/register",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: RegistrationScreen());
        },
      ),
      GoRoute(
        path: "/sigin",
        pageBuilder: (context, state) {
          return NoTransitionPage(child: SignInScreen());
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
        path: "/inbox",
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: InboxScreen());
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
          return const NoTransitionPage(child: LoginScreen());
        },
      ),
      GoRoute(
        path: "/c/create",
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: CreateComunityScreen());
        },
      ),
      GoRoute(
        path: "/chat/:uid/:chatid",
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: ChatScreen(
              targetUserID: state.pathParameters['uid']!,
              chatID: state.pathParameters['chatid']!,
            ),
          );
        },
      ),
      GoRoute(
        path: "/dash",
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: DashScreen(),
          );
        },
      ),
      GoRoute(
        name: Navigation.addDash,
        path: "/dash/create",
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: AddNewDash(
              path: state.extra as Map<String, dynamic>,
            ),
          );
        },
      ),
      GoRoute(
        name: Navigation.dashview,
        path: "/dash/view",
        builder: (context, state) {
          return DashViewScreen(
            data: state.extra as Map<String, dynamic>,
          );
        },
      ),
      GoRoute(
        path: '/dash/view/:extra',
        builder: (context, state) {
          final extraData =
              jsonDecode(Uri.decodeComponent(state.pathParameters['extra']!));
          return DashViewScreen(data: extraData);
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
          return const NoTransitionPage(child: MySttScreen());
        },
      ),
      GoRoute(
        path: "/following/:uid",
        pageBuilder: (context, state) {
          return NoTransitionPage(
              child: FollowingScreen(
            userID: state.pathParameters['uid']!,
          ));
        },
      ),
      GoRoute(
        path: "/followers/:uid",
        pageBuilder: (context, state) {
          return NoTransitionPage(
              child: FollowersScreen(
            userID: state.pathParameters['uid']!,
          ));
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
          return const NoTransitionPage(child: AddPostScreen());
        },
      ),
      GoRoute(
        path: "/update",
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SizedBox());
        },
      ),
    ],
    // redirect: (context, state) {
    //   // If our async state is loading, don't perform redirects, yet
    //   if (authState.isLoading || authState.hasError) return null;

    //   // Here we guarantee that hasData == true, i.e. we have a readable value

    //   // This has to do with how the FirebaseAuth SDK handles the "log-in" state
    //   // Returning `null` means "we are not authorized"
    //   final isAuth = authState.valueOrNull != null;

    //   final isLoggingIn = state.matchedLocation == "/login";
    //   // final isSplash = state.matchedLocation == "/splash";
    //   // if (isSplash) return isAuth ? "/" : "/login";
    //   if (isLoggingIn) return isAuth ? "/" : null;

    //   return isAuth ? null : "/login";
    // },
  );
});
