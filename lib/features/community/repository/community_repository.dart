// ignore_for_file: void_checks

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/core/type_defs.dart';
import 'package:viblify_app/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunitRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class CommunitRepository {
  final supabase = Supabase.instance.client;
  final FirebaseFirestore _firebaseFirestore;
  CommunitRepository({required FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc =
          await supabase.from(FirebaseConstant.communitiesCollection).select().eq("id", community.id).limit(1);
      if (communityDoc.isNotEmpty) {
        throw 'Community with the same name already exists!';
      }

      return right(await supabase.from(FirebaseConstant.communitiesCollection).insert(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userID) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userID])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userID) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userID])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    try {
      return supabase
          .from(FirebaseConstant.communitiesCollection)
          .stream(primaryKey: ['id']).map((data) => data.map(Community.fromMap).toList());
    } catch (error) {
      log("Error getting user communities: $error");
      rethrow;
    }
  }

  Stream<Community> getCommunityByName(String name) {
    return supabase
        .from(FirebaseConstant.communitiesCollection)
        .stream(primaryKey: ['id'])
        .eq("name", name)
        .limit(1)
        .map((event) => Community.fromMap(event.first));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(
          supabase.from(FirebaseConstant.communitiesCollection).update(community.toMap()).eq("name", community.name));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      final response =
          await supabase.from(FirebaseConstant.communitiesCollection).select().eq('name', communityName).single();
      final existingMods = response['mods'] as List<dynamic>;
      for (String uid in uids) {
        existingMods.add(uid);
      }
      return right(await supabase
          .from(FirebaseConstant.communitiesCollection)
          .update({"mods": existingMods}).eq("name", communityName));
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
    final db = supabase
        .from(FirebaseConstant.communitiesCollection)
        .select()
        .gte('name', query.isEmpty ? 0 : query)
        .lt('name', value!)
        .asStream();
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
      final response =
          supabase.from(FirebaseConstant.communitiesCollection).stream(primaryKey: ['id']).eq('name', name).limit(1);
      log("message");

      // Return true if the username is taken otherwise false
      return response.length != 0;
    } catch (error) {
      log("Error checking username: $error");
      rethrow;
    }
  }

  CollectionReference get _communities => _firebaseFirestore.collection(FirebaseConstant.communitiesCollection);
}
