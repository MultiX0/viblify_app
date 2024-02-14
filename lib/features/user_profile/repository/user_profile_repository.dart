// ignore_for_file: void_checks

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../../core/Constant/firebase_constant.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class UserRepository {
  final FirebaseFirestore _firebaseFirestore;
  UserRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstant.usersCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.userID).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> toggleFollow(String userID, followerID) async {
    // Update the current user's following list
    final followingRef = _users.doc(userID);
    final isFollowing = await followingRef
        .get()
        .then((doc) => doc['following']?.contains(followerID) ?? false);

    if (isFollowing) {
      await followingRef.update({
        'following': FieldValue.arrayRemove([followerID])
      });
    } else {
      await followingRef.update({
        'following': FieldValue.arrayUnion([followerID])
      });
    }

    // Update the other user's followers list
    final otherUserRef = _users.doc(followerID);
    final isFollowedByOtherUser = await otherUserRef
        .get()
        .then((doc) => doc['followers']?.contains(userID) ?? false);

    if (isFollowedByOtherUser) {
      await otherUserRef.update({
        'followers': FieldValue.arrayRemove([userID])
      });
    } else {
      await otherUserRef.update({
        'followers': FieldValue.arrayUnion([userID])
      });
    }
  }

  late http.Client client;

  FutureVoid downloadImage(String imgUrl) async {
    client = http.Client();
    try {
      final response = await client.get(Uri.parse(imgUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        final directory = Directory("/storage/emulated/0/Download/Viblify");
        if ((await directory.exists())) {
          print("exist");
        } else {
          print("not exist");
          directory.create();
        }
        const chars = '1234567890';
        final random = Random();
        final id =
            List.generate(13, (index) => chars[random.nextInt(chars.length)])
                .join();

        final file = File('${directory.path}/$id.jpg');
        // Save the image to the gallery
        await ImageGallerySaver.saveImage(Uint8List.fromList(bytes),
            name: file.path);

        return right(await file.writeAsBytes(bytes));
      } else {
        return left(Failure(response.statusCode.toString()));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    } finally {
      client.close();
    }
  }

  Stream<bool> isFollowingTheUserStream(String userID, String followerID) {
    final followingRef = _users.doc(userID);

    return followingRef.snapshots().map((doc) {
      return doc['followers']?.contains(followerID) ?? false;
    });
  }

  Future<bool> isUsernameTaken(String username, String currentUserId) {
    return _users
        .where('userName', isEqualTo: username)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        // Check if the existing username belongs to the current user
        final userDoc = querySnapshot.docs.first;
        final existingUserId = userDoc['userID'] as String;

        // If the existing username belongs to the current user, return true
        if (existingUserId == currentUserId) {
          return true;
        }

        // If the existing username does not belong to the current user, return false
        return false;
      }

      // If the username is not taken, return true
      return true;
    });
  }
}
