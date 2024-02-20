import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/splash_screen/splash_screen.dart';
import 'package:viblify_app/router.dart';
import 'features/remote_config/repository/remote_config_repository.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'theme/Pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Pallete.blackColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
  UserModel? userModel;
  String appVersion = '';
  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;

    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    await Future.delayed(
        Duration.zero); // Introduce a delay to wait for the build to complete

    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return ref.watch(authChangeState).when(
          data: (data) => ref.read(updateInfoProvider).when(
                data: (update) {
                  if (data != null) {
                    getData(ref, data);
                  } else {
                    print('not logged in');
                  }
                  if (appVersion.isNotEmpty &&
                      update.version.isNotEmpty &&
                      Version.parse(appVersion) <
                          Version.parse(update.version)) {
                    return MaterialApp(
                      theme: Pallete.darkModeAppTheme,
                      debugShowCheckedModeBanner: false,
                      home: const Scaffold(
                        body: Center(
                          child: Text(
                            'new update!',
                            style: TextStyle(
                              fontSize: 65,
                              fontFamily: "LobsterTwo",
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return MaterialApp.router(
                      routeInformationParser: router.routeInformationParser,
                      routerDelegate: router.routerDelegate,
                      routeInformationProvider: router.routeInformationProvider,
                      debugShowCheckedModeBanner: false,
                      theme: Pallete.darkModeAppTheme,
                      title: "viblify",
                    );
                  }
                },
                error: (error, trace) => ErrorText(error: error.toString()),
                loading: () => MaterialApp(
                  theme: Pallete.darkModeAppTheme,
                  debugShowCheckedModeBanner: false,
                  home: const TitleWidget(),
                ),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => MaterialApp(
            theme: Pallete.darkModeAppTheme,
            debugShowCheckedModeBanner: false,
            home: const TitleWidget(),
          ),
        );
  }
}
