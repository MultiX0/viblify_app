// ignore_for_file: void_checks, unnecessary_null_comparison

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/features/community/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunitRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class CommunitRepository {
  final supabase = Supabase.instance.client;
  CommunitRepository({required FirebaseFirestore firebaseFirestore});

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.select().eq("id", community.id).limit(1);
      if (communityDoc.isNotEmpty) {
        throw 'Community with the same name already exists!';
      }

      return right(await _communities.insert(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userID) async {
    try {
      final response = await _communities.select().eq('name', communityName).single();
      final existingMods = response['members'] as List<dynamic>;
      existingMods.add(userID);
      return right(await _communities.update({"members": existingMods}).eq("name", communityName));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userID) async {
    try {
      final response = await _communities.select().eq('name', communityName).single();
      final existingMods = response['members'] as List<dynamic>;
      existingMods.remove(userID);
      return right(await _communities.update({"members": existingMods}).eq("name", communityName));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .stream(primaryKey: ['id'])
        .map((data) => data.map(Community.fromMap).toList())
        .map((communities) =>
            communities.where((community) => community.members.contains(uid)).toList());
  }

  Stream<Community> getCommunityByName(String name) {
    try {
      return _communities
          .stream(primaryKey: ['id'])
          .eq("name", name)
          .map((data) => Community.fromMap(data.first));
    } catch (error) {
      log("Error getting community by name: $error");
      rethrow;
    }
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(await _communities.update(community.toMap()).eq("name", community.name));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(await _communities.update({"mods": uids}).eq("name", communityName));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    final value = query.isEmpty
        ? null
        : query.substring(0, query.length - 1) +
            String.fromCharCode(
              query.codeUnitAt(query.length - 1) + 1,
            );
    final db =
        _communities.select().gte('name', query.isEmpty ? 0 : query).lt('name', value!).asStream();
    return db.map((event) {
      List<Community> communities = [];
      for (var community in event) {
        communities.add(Community.fromMap(community));
      }
      return communities;
    });
  }

  Future<bool> isUsernameTaken(String name) async {
    try {
      final response = await _communities.select().eq('name', name).limit(1).single();
      if (response == null) {
        log('No data found');
        return true;
      }

      if (response != null) {
        log('No data found 2');
        return true;
      }

      log('Data found');
      return false;
    } catch (error) {
      log('Error checking username: ${error.toString()}');
      rethrow;
    }
  }

  SupabaseQueryBuilder get _communities => supabase.from(FirebaseConstant.communitiesCollection);
}
