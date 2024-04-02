// ignore_for_file: void_checks, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final supabase = Supabase.instance.client;
  UserRepository({required FirebaseFirestore firebaseFirestore});
  SupabaseQueryBuilder get _users =>
      supabase.from(FirebaseConstant.usersCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(await _users.update(user.toMap()).eq("userID", user.userID));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> toggleFollow(String userID, followerID) async {
    // Update the current user's following list
    // final followingRef = _users.doc(userID);
    var ref = await _users.select().eq("userID", userID).single();

    final isFollowing = await ref['following']?.contains(followerID) ?? false;
    List<String> list = ref['following'];
    if (isFollowing) {
      list.remove(followerID);
      await _users.update({"following": list}).eq("userID", userID);
    } else {
      list.add(followerID);
      await _users.update({"following": list}).eq("userID", userID);
    }

    // Update the other user's followers list
    // final otherUserRef = _users.doc(followerID);
    var otherRef = await _users.select().eq("userID", followerID).single();
    final isFollowedByOtherUser =
        await otherRef['followers']?.contains(userID) ?? false;

    List<String> otherList = await otherRef['followers'];

    if (isFollowedByOtherUser) {
      otherList.remove(userID);
      await _users.update({"followers": otherList}).eq("userID", followerID);
    } else {
      otherList.add(userID);
      await _users.update({"followers": otherList}).eq("userID", followerID);
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
        const chars =
            '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
        final random = Random();
        final id =
            List.generate(20, (index) => chars[random.nextInt(chars.length)])
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

  Stream<List<UserModel>> searchUsers(String query) {
    final value = query.isEmpty
        ? null
        : query.substring(0, query.length - 1) +
            String.fromCharCode(
              query.codeUnitAt(query.length - 1) + 1,
            );
    final db = _users
        .select()
        .gte('userName', query.isEmpty ? 0 : query)
        .lt('userName', value!)
        .asStream();
    return db.map((event) {
      List<UserModel> users = [];
      for (var user in event) {
        users.add(UserModel.fromMap(user));
      }
      return users;
    });
  }

  Stream<bool> isFollowingTheUserStream(String userID, String followerID) {
    // final followingRef = _users.doc(userID);

    return _users
        .stream(primaryKey: ['userID'])
        .eq("userID", userID)
        .map((doc) {
          if (doc.isNotEmpty) {
            return doc.first['followers']?.contains(followerID) ?? false;
          } else {
            return false;
          }
        });
  }

  Stream<List<dynamic>> getFollowersStream(String userID) {
    return _users
        .stream(primaryKey: ['userID'])
        .eq('userID', userID)
        .map((response) {
          if (response.isEmpty) {
            // Error occurred or no data found, return an empty list
            return [];
          }

          final List<dynamic>? documentData = response[0]['followers'];
          if (documentData == null) {
            // 'followers' field is missing or null, return an empty list
            return [];
          }

          return documentData;
        });
  }

  Stream<List<dynamic>> getFollowingStream(String userID) {
    return _users
        .stream(primaryKey: ['userID'])
        .eq('userID', userID)
        .map((response) {
          if (response.isEmpty) {
            // Error occurred or no data found, return an empty list
            return [];
          }

          final List<dynamic>? documentData = response[0]['following'];
          if (documentData == null) {
            // 'followers' field is missing or null, return an empty list
            return [];
          }

          return documentData;
        });
  }

  Future<bool> isUsernameTaken(String username, String currentUserId) async {
    final response = await _users.select().eq('userName', username).single();

    if (response.isNotEmpty) {
      // Handle error here if needed
      return false;
    }

    final List<dynamic>? data = response as List<dynamic>?;

    if (data != null && data.isNotEmpty) {
      final existingUserId = data[0]['userID'] as String;
      if (existingUserId == currentUserId) {
        return true;
      }
      return false;
    }

    return true;
  }

  Future<void> updateProfileTheme(
      String uid, String color, String dividerColor, bool isThemeDark) async {
    await _users.update({
      'profile_theme': color,
      'divider_color': dividerColor,
      'is_theme_dark': isThemeDark,
    }).eq("userID", uid);
  }

  Future<void> updateActiveStatus(bool isOnline, String uid) async {
    await _users.update({
      'isUserOnline': isOnline,
      'lastTimeActive': DateTime.now().millisecondsSinceEpoch.toString(),
    }).eq("userID", uid);
  }
}
