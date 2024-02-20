import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import 'package:viblify_app/models/app_version.dart';

final firebaseRemoteConfigServiceProvider =
    Provider<FirebaseRemoteConfigService>((ref) {
  final remoteConfigService = FirebaseRemoteConfigService(
    firebaseRemoteConfig: FirebaseRemoteConfig.instance,
  );
  remoteConfigService.init();
  return remoteConfigService;
});

final updateInfoProvider = FutureProvider<UpdateInfo>((ref) async {
  final remoteConfigService = ref.read(firebaseRemoteConfigServiceProvider);

  // Check for updates
  return remoteConfigService.checkForUpdate();
});

class FirebaseRemoteConfigService {
  const FirebaseRemoteConfigService({
    required this.firebaseRemoteConfig,
  });

  final FirebaseRemoteConfig firebaseRemoteConfig;

  Future<void> init() async {
    try {
      await firebaseRemoteConfig.ensureInitialized();
      await firebaseRemoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await firebaseRemoteConfig.fetchAndActivate();
    } on FirebaseException catch (e, st) {
      developer.log(
        'Unable to initialize Firebase Remote Config',
        error: e,
        stackTrace: st,
      );
    }
  }

  String getAppVersionJson() => firebaseRemoteConfig.getString('app_version');

  // Parse JSON and check for updates
  UpdateInfo checkForUpdate() {
    try {
      final json = getAppVersionJson();
      final Map<String, dynamic> data = jsonDecode(json);

      final String version = data['version'];
      final int buildNumber = data['buildNumber'];
      final bool isOptional = data['is_optional'];

      // Perform logic to compare version and build number with current app version
      // Return an UpdateInfo object with the details
      return UpdateInfo(version, buildNumber, isOptional);
    } catch (e) {
      // Handle JSON parsing errors
      developer.log(
        'Error parsing app_version JSON',
        error: e.toString(),
      );
      // Return a default UpdateInfo if parsing fails
      return UpdateInfo('0.0.0', 0, false);
    }
  }
}
