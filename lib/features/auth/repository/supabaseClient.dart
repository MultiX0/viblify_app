// ignore_for_file: file_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/models/user_model.dart';

class SupabaseUser {
  final supabase = Supabase.instance.client;
  Future<void> newUser(UserModel user) async {
    try {
      await supabase.from(FirebaseConstant.usersCollection).insert(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
