import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/repository/auth_repository.dart';
import 'package:viblify_app/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});
final getUserByName = StreamProvider.family((ref, String userName) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserDataByName(userName);
});

final authChangeState = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChanges;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChanges => _authRepository.authStateChanged;
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  Stream<UserModel> getUserDataByName(String name) {
    return _authRepository.getUserDataByName(name);
  }

  Future<String> getUserIdByName(String name) {
    return _authRepository.getUserIdByName(name);
  }

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold(
        (l) => showSnackBar(context, l.message),
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }
}
