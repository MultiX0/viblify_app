import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';

class UpdateUserStatus {
  final _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstant.usersCollection);

  Future<void> updateActiveStatus(bool isOnline, String uid) async {
    await _users.doc(uid).update({
      'isUserOnline': isOnline,
      'lastTimeActive': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }
}
