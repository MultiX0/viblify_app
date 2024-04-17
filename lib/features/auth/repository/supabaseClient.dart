// ignore_for_file: file_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';

class SupabaseUser {
  final supabase = Supabase.instance.client;
  Future<void> newUser(Map<String, dynamic> user) async {
    try {
      await supabase.from(FirebaseConstant.usersCollection).insert(user);
    } catch (e) {
      rethrow;
    }
  }

  static Stream<UserModel> getUserData(String uid) {
    final supabase = Supabase.instance.client;
    return supabase
        .from(FirebaseConstant.usersCollection)
        .stream(primaryKey: ['userID'])
        .eq('userID', uid)
        .limit(1)
        .map((data) => UserModel.fromMap(data.first));
  }
}
