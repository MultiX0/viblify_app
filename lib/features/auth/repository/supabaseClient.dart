// ignore_for_file: file_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';

class SupabaseUser {
  final supabase = Supabase.instance.client;
  Future<void> newUser(Map<String, dynamic> user) async {
    try {
      await supabase.from(FirebaseConstant.usersCollection).insert(user);
    } catch (e) {
      rethrow;
    }
  }
}
