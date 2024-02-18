import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/auth/screens/login_screen.dart';
import 'package:viblify_app/features/home/screens/home_screen.dart';

import 'features/user_profile/screens/user_profile_screen.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'theme/Pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;

    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authChangeState).when(
        data: (data) {
          if (data != null) {
            getData(ref, data);
          }
          return MaterialApp(
            home: userModel != null ? const HomeScreen() : const LoginScreen(),
            debugShowCheckedModeBanner: false,
            theme: Pallete.darkModeAppTheme,
            title: "viblify",
            onGenerateRoute: (settings) {
              if (settings.name != null &&
                  settings.name!.startsWith('https://viblify.com/u/')) {
                // Handle user profile deep link
                List<String> parts = settings.name!.split('/');
                if (parts.length == 5) {
                  String userId = parts[4]; // Extract user ID from the URL
                  return MaterialPageRoute(
                    builder: (context) => UserProfileScreen(uid: userId),
                  );
                }
              }
              print(settings.name);

              return MaterialPageRoute(
                builder: (context) => const Center(
                  child: Text("Page not exist"),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
        loading: () => const Loader());
  }
}
