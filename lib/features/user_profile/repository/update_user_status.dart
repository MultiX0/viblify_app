import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/messaging/notifications.dart';

class UpdateUserStatus {
  final supabase = Supabase.instance.client;
  final _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference get _users => _firebaseFirestore.collection(FirebaseConstant.usersCollection);

  Future<void> updateActiveStatus(bool isOnline, String uid) async {
    String token = await ViblifyNotifications().initNotifications();
    await _users.doc(uid).update({
      'isUserOnline': isOnline,
      'lastTimeActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'notificationsToken': token,
    });
    // await supabase
    //     .from(FirebaseConstant.usersCollection)
    //     .update({
    //       'isUserOnline': isOnline,
    //       'lastTimeActive': DateTime.now().millisecondsSinceEpoch.toString(),
    //       'notificationsToken': token,
    //     })
    //     .eq('userID', uid)
    //     .single();
  }
}
