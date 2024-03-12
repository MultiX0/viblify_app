import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/messaging/notifications.dart';

class UpdateUserStatus {
  final _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstant.usersCollection);

  Future<void> updateActiveStatus(bool isOnline, String uid) async {
    String token = await ViblifyNotifications().initNotifications();
    await _users.doc(uid).update({
      'isUserOnline': isOnline,
      'lastTimeActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'notificationsToken': token,
    });
  }
}
