import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';

class UpdateMessagesStatus {
  final _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference get _messages =>
      _firebaseFirestore.collection(FirebaseConstant.chatsCollection);

  Future<void> updateMessageStatus(
      String targetUser, String me, String chatID, String messageID) async {
    try {
      var chatRef = _messages.doc(chatID);
      chatRef.collection(targetUser).doc(messageID).update({"seen": true});
      chatRef.collection(me).doc(messageID).update({"seen": true});
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> inTheChatStatus(String chatID, String myID) async {
  //   try {
  //     var chatRef = _messages.doc(chatID);

  //     var inchatMembers = (await chatRef.get())["inTheChat"] ?? [];

  //     if (inchatMembers.contains(myID)) {
  //       chatRef.update({
  //         "inTheChat": FieldValue.arrayRemove([myID])
  //       });
  //     } else {
  //       chatRef.update({
  //         "inTheChat": FieldValue.arrayUnion([myID])
  //       });
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> updateChatRoomStatus(
      String sender, String reciver, String chatID, bool typing) async {
    try {
      var chatRef = _firebaseFirestore
          .collection("users")
          .doc(reciver)
          .collection(FirebaseConstant.chatsCollection)
          .doc(sender);
      var path = await _firebaseFirestore
          .collection("users")
          .doc(reciver)
          .collection(FirebaseConstant.chatsCollection)
          .doc(sender)
          .get();

      if (typing && path.exists) {
        chatRef.update({
          "typing": FieldValue.arrayUnion([sender])
        });
        // If typing is true and user ID is not already in the list, add it
      } else {
        chatRef.update({
          "typing": FieldValue.arrayRemove([sender])
        });
      }

      // Return true indicating a successful update
    } catch (e) {
      // Return false if an error occurs
    }
  }
}
