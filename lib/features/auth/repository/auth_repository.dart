import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstant.usersCollection);

  Stream<User?> get authStateChanged => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel userModel;
      String randomUsername = generateRandomUsername();

      if (userCredential.additionalUserInfo!.isNewUser) {
        Future<String> generateUniqueUsername() async {
          String randomUsername;

          Future<bool> isUsernameTaken(String username) {
            return _users
                .where('userName', isEqualTo: username)
                .limit(1)
                .get()
                .then((QuerySnapshot querySnapshot) => querySnapshot.size > 0);
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

        // Proceed with creating the new user
        userModel = UserModel(
          name: userCredential.user!.displayName ?? "Unknown",
          profilePic: userCredential.user!.photoURL ?? Constant.avatarDefault,
          bannerPic: Constant.bannerDefault,
          userID: userCredential.user!.uid,
          isAccountPrivate: false,
          isUserMod: false,
          link: '',
          email: userCredential.user!.email!,
          verified: false,
          bio: "",
          location: "",
          joinedAt: DateTime.now(),
          userName: randomUsername,
          following: [],
          followers: [],
          points: 0,
        );

        await _users.doc(userModel.userID).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  String generateRandomUsername() {
    const allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789_';

    Random random = Random();
    int length =
        random.nextInt(6) + 5; // Generates a random length between 5 and 10
    StringBuffer usernameBuffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(allowedChars.length);
      usernameBuffer.write(allowedChars[randomIndex]);
    }

    return usernameBuffer.toString();
  }
}
