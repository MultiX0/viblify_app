import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/splash_screen/splash_screen.dart';
import 'package:viblify_app/router.dart';
import 'package:viblify_app/supabase_options.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'features/remote_config/repository/remote_config_repository.dart';
import 'firebase_options.dart';
import 'features/auth/models/user_model.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "messages",
  "Messages",
  description: "This Message Notifications",
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackGroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  String imageUrl = message.data["image"] ?? "";
  String title = message.data["title"] ?? "";
  String body = message.data["body"] ?? "";
  final String largeIcon = await _base64encodedImage(imageUrl);
  flutterLocalNotificationsPlugin.show(
    message.notification.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        color: Colors.blue,
        playSound: true,
        icon: "@mipmap/ic_launcher_monochrome",
        channelDescription: channel.description,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
      ),
    ),
  );
}

Future<String> _base64encodedImage(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  final String base64Data = base64Encode(response.bodyBytes);
  return base64Data;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xff0d0d0d),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAuth.instance.signOut();
  await SupabaseOptions.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackGroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final firebaseRemoteConfigService = FirebaseRemoteConfigService(
    firebaseRemoteConfig: FirebaseRemoteConfig.instance,
  );
  await firebaseRemoteConfigService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final firestore = FirebaseFirestore.instance;
  UserModel? userModel;
  String appVersion = '';
  int buildNumber = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadAppVersion();
    _setupNotifications();
  }

  Future<void> getData(WidgetRef ref, User data) async {
    try {
      Timer(const Duration(seconds: 1), () async {
        var querySnapshot = await firestore
            .collection(FirebaseConstant.usersCollection)
            .where("userID", isEqualTo: data.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          userModel = UserModel.fromMap(querySnapshot.docs.first.data());
          ref.watch(userProvider.notifier).update((state) => userModel);
          setState(() {
            isLoading = false;
          });
        } else {
          log('No user data found for user_id: ${data.uid}');
        }
      });
    } catch (e) {
      log('Failed to fetch user data: $e');
    }
  }

  void _setupNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String imageUrl = message.data["image"] ?? "";
      String title = message.data["title"] ?? "";
      String body = message.data["body"] ?? "";
      final String largeIcon = await _base64encodedImage(imageUrl);

      flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            color: Colors.blue,
            playSound: true,
            icon: "@mipmap/ic_launcher_monochrome",
            channelDescription: channel.description,
            largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
          ),
        ),
      );
    });
  }

  Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return base64Encode(response.bodyBytes);
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      buildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    });
    log("The Build Number is :$buildNumber");
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);

    return MaterialApp(
      theme: Pallete.darkModeAppTheme,
      debugShowCheckedModeBanner: false,
      home: ref.watch(authStateChangeProvider).when(
            data: (data) => ref.read(updateInfoProvider).when(
                  data: (update) {
                    if (data != null) {
                      if (isLoading) {
                        getData(ref, data);
                        return _buildLoadingApp();
                      }
                    } else {
                      log('Not logged in');
                    }
                    if (appVersion.isNotEmpty &&
                            update.version.isNotEmpty &&
                            Version.parse(appVersion) < Version.parse(update.version) ||
                        buildNumber < update.buildNumber) {
                      return _buildUpdateApp();
                    } else {
                      return _buildMainApp(router);
                    }
                  },
                  error: (error, trace) => ErrorText(error: error.toString()),
                  loading: () => _buildLoadingApp(),
                ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => _buildLoadingApp(),
          ),
    );
  }

  MaterialApp _buildUpdateApp() {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      navigatorKey: navigatorKey,
      theme: Pallete.darkModeAppTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text(
            'New update!',
            style: TextStyle(
              fontSize: 65,
              fontFamily: "LobsterTwo",
            ),
          ),
        ),
      ),
    );
  }

  MaterialApp _buildMainApp(GoRouter router) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      theme: Pallete.darkModeAppTheme,
      title: "Viblify",
    );
  }

  Widget _buildLoadingApp() {
    return const TitleWidget();
  }
}
