// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/features/auth/repository/supabaseClient.dart';
import 'package:viblify_app/messaging/notifications.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _auth = auth,
        _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstant.usersCollection);

  Stream<User?> get authStateChanged => _auth.authStateChanges();

  FutureEither<UserModel> registerWithEmail(String email, String password, String username) async {
    try {
      UserModel userModel;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Future<String> generateUniqueUsername() async {
        String randomUsername;

        Future<bool> isUsernameTaken(String username) async {
          var querySnapshot = await _users.where('userName', isEqualTo: username).limit(1).get();
          return querySnapshot.docs.isNotEmpty;
        }

        bool taken;
        do {
          // Generate a new random username
          randomUsername = generateRandomUsername();

          // Check if the username is already taken
          taken = await isUsernameTaken(randomUsername);

          // If taken, generate a new one and repeat the loop
        } while (taken);

        return randomUsername;
      }

      String randomUsername = await generateUniqueUsername();

      // Proceed with creating the new user
      String notificationsToken = await ViblifyNotifications().initNotifications();

      userModel = UserModel(
        name: username,
        profilePic: Constant.userIcon,
        bannerPic: Constant.bannerDefault,
        notificationsToken: notificationsToken,
        userID: userCredential.user!.uid,
        dividerColor: "#212121",
        isThemeDark: true,
        isAccountPrivate: false,
        isUserMod: false,
        mbti: "",
        link: '',
        lastTimeActive: '',
        isUserOnline: false,
        email: userCredential.user!.email!,
        verified: false,
        bio: "",
        location: "",
        stt: false,
        isUserBlocked: false,
        joinedAt: DateTime.now(),
        userName: randomUsername,
        following: [],
        followers: [],
        notifications: [],
        postLikes: [],
        usersBlock: [],
        password: encrypt(password, encryptKey),
        profileTheme: "#0d0d0d",
        points: 0,
      );

      await _users.doc(userModel.userID).set(userModel.toMap());
      SupabaseUser().newUser(userModel.toMap());

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    } on FirebaseException catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureEither<UserModel> signInWithEmail(String email, String password) async {
    try {
      UserModel userModel;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      userModel = await getUserData(userCredential.user!.uid).first;
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Future<String> getUserIdByName(String name) async {
    QuerySnapshot event = await _users.where("userName", isEqualTo: name).get();

    if (event.docs.isNotEmpty) {
      // Assuming the document ID is the user ID
      return event.docs.first.id;
    } else {
      // Handle the case when no user with the specified name is found
      // Return null or throw an exception based on your requirements
      // ignore: null_check_always_fails
      return null!;
    }
  }

  Stream<UserModel> getUserDataByName(String name) {
    return _users.where("userName", isEqualTo: name).snapshots().map(
      (QuerySnapshot event) {
        if (event.docs.isNotEmpty) {
          return UserModel.fromMap(event.docs.first.data() as Map<String, dynamic>);
        } else {
          // Handle the case when no user with the specified name is found
          // ignore: null_check_always_fails
          return null!; // Or throw an exception or return a default user
        }
      },
    );
  }

  String generateRandomUsername() {
    const allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789_';

    Random random = Random();
    int minLength = 10;
    int maxLength = 15;
    int length = minLength +
        random.nextInt(maxLength - minLength + 1); // Generates a random length between 10 and 15

    StringBuffer usernameBuffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(allowedChars.length);
      usernameBuffer.write(allowedChars[randomIndex]);
    }

    return usernameBuffer.toString();
  }
}
