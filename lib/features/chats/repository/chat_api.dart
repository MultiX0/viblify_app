import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';

final _firestore = FirebaseFirestore.instance;

class ChatApi {
  Future<void> deleteMessageFromMe(
      String reciverID, String targetID, String messageID) async {
    try {
      final chatPath = _firestore
          .collection(FirebaseConstant.usersCollection)
          .doc(targetID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(reciverID)
          .collection(FirebaseConstant.meassageCollection);
      chatPath.doc(messageID).delete();
    } catch (e) {
      rethrow;
    }
  }
}
