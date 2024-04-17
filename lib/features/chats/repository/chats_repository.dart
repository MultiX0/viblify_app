import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/features/chats/models/chats_model.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils.dart';
import '../models/chat_room_status.dart';
import '../models/chat_status_model.dart';
import '../../../models/message_model.dart';

final chatsRepositoryProvider = Provider((ref) {
  return ChatsRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class ChatsRepository {
  final FirebaseFirestore _firebaseFirestore;
  ChatsRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;
  CollectionReference get _chats => _firebaseFirestore.collection(FirebaseConstant.chatsCollection);

  var uuid = const Uuid();

  Future<ChatModel?> getChatRoom(
    UserModel userModel,
    UserModel targetUser,
    ChatModel chatModel,
  ) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(userModel.userID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(targetUser.userID)
          .get();
      if (snapshot.exists) {
        log("isAvailable");
        return chatModel;
      } else {
        log("ChatRoom not created");

        final chat = ChatModel.fromMap({
          "id": targetUser.userID,
          "lastMessage": "تم فتح المحادثة",
          "createdAt": Timestamp.now(),
          "typing": [],
          "type": "chat",
          "inTheChat": [],
          "lastMessageDate": Timestamp.now(),
        });
        await _firebaseFirestore
            .collection(FirebaseConstant.usersCollection)
            .doc(userModel.userID)
            .collection(FirebaseConstant.chatsCollection)
            .doc(targetUser.userID)
            .set(chat.toMap());
      }
    } catch (e) {
      rethrow;
    }
    return chatModel;
  }

  Future<void> sendMessage(String reciverID, String senderID, MessageModel message) async {
    final chatPath = await _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(senderID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(reciverID)
        .get();

    if (!chatPath.exists) {
      final chat = ChatModel.fromMap({
        "id": reciverID,
        "lastMessage": "تم فتح المحادثة",
        "createdAt": Timestamp.now(),
        "typing": [],
        "type": "chat",
        "inTheChat": [],
        "lastMessageDate": Timestamp.now(),
      });
      log("Document dose not exists!");

      await _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(senderID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(reciverID)
          .set(chat.toMap());
    }
    //reciver
    final reciverChatPath = await _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(reciverID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(senderID)
        .get();
    if (!reciverChatPath.exists) {
      log("Document dose not exists!");
      final chat = ChatModel.fromMap({
        "id": senderID,
        "lastMessage": "تم فتح المحادثة",
        "createdAt": Timestamp.now(),
        "typing": [],
        "type": "chat",
        "inTheChat": [],
        "lastMessageDate": Timestamp.now(),
      });

      await _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(reciverID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(senderID)
          .set(chat.toMap());
    }

    //target message:
    final senderPath = _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(senderID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(reciverID)
        .collection(FirebaseConstant.meassageCollection);
    final result1 = senderPath.doc(message.messageid).set(message.toMap());
    //reciver message:
    final reciverPath = _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(reciverID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(senderID)
        .collection(FirebaseConstant.meassageCollection);
    final result2 = reciverPath.doc(message.messageid).set(message.toMap());

    //editTheChatRoom
    final chatRoomSender = _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(senderID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(reciverID)
        .update({
      "lastMessage": message.text,
      "lastMessageDate": Timestamp.now(),
    });
    //editTheRoom in reciver data
    final chatRoomReciver = _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(reciverID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(senderID)
        .update({
      "lastMessage": message.text,
      "lastMessageDate": Timestamp.now(),
    });
    //edit
    await chatRoomReciver;
    await chatRoomSender;
    //results :
    await result1;
    await result2;
  }

  Stream<List<MessageModel>> getAllMessages(String chatID, String userID) {
    return _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(userID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(chatID)
        .collection(FirebaseConstant.meassageCollection)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var doc in event.docs) {
        messages.add(
          MessageModel.fromMap(
            doc.data(),
          ),
        );
      }
      return messages;
    });
  }

  Stream<List<ChatModel>> getAllInboxMessages(String userID) {
    try {
      final data = _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(userID)
          .collection(FirebaseConstant.chatsCollection)
          .orderBy("lastMessageDate", descending: true);

      final result = data.snapshots().map((dataList) {
        List<ChatModel> chats = [];
        for (var doc in dataList.docs) {
          chats.add(
            ChatModel.fromMap(
              doc.data(),
            ),
          );
        }
        return chats;
      });
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Stream<ChatModel> getChatByID(String myID, String targetID) {
    return _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(myID)
        .collection(FirebaseConstant.chatsCollection)
        .doc(targetID)
        .snapshots()
        .map((doc) {
      return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Stream<ChatStatus> chatStatusStream(String chatId, String myUserId) {
    final controller = StreamController<ChatStatus>();

    _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(myUserId)
        .collection(FirebaseConstant.chatsCollection)
        .doc(chatId)
        .snapshots()
        .listen((chatSnapshot) {
      if (chatSnapshot.exists) {
        _firebaseFirestore
            .collection(FirebaseConstant.usersCollection)
            .doc(myUserId)
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((messagesSnapshot) {
          if (messagesSnapshot.docs.isNotEmpty) {
            var unreadMessages = messagesSnapshot.docs
                .where((messageDoc) =>
                    messageDoc.get('sender') != myUserId && messageDoc.get('seen') == false)
                .toList();

            bool sentByMe = messagesSnapshot.docs.first.get('sender') == myUserId;
            bool isSeen = messagesSnapshot.docs.first.get('seen') ?? false;

            int unseenMessagesCount = unreadMessages.length;

            controller.add(ChatStatus(
              sentByMe: sentByMe,
              lastMessageSeen: isSeen,
              unseenMessagesCount: unseenMessagesCount,
            ));
          } else {
            controller.add(ChatStatus(
              sentByMe: false,
              lastMessageSeen: true,
              unseenMessagesCount: 0,
            ));
          }
        });
      } else {
        controller.addError(StateError('Chat not found'));
      }
    });

    return controller.stream;
  }

  Stream<StatusRoomModel> memberStatusStream(String sender, String reciver) {
    final controller = StreamController<StatusRoomModel>();

    _firebaseFirestore
        .collection(FirebaseConstant.usersCollection)
        .doc(sender)
        .collection(FirebaseConstant.chatsCollection)
        .doc(reciver)
        .snapshots()
        .listen((chatDocSnapshot) {
      if (chatDocSnapshot.exists) {
        List<dynamic>? typingUsers = chatDocSnapshot.get('typing');

        if (typingUsers != null && typingUsers.contains(reciver)) {
          controller.add(StatusRoomModel(typing: true));
        } else {
          controller.add(StatusRoomModel(typing: false));
        }
      } else {
        controller.addError(StateError('Chat not found'));
      }
    });

    return controller.stream;
  }

  void setChatMessageSeen(BuildContext context, String reciverUserID, String senderID,
      String messageID, String chatID) async {
    try {
      log("work");
      //edit for the user
      _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(reciverUserID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(senderID)
          .collection(FirebaseConstant.meassageCollection)
          .doc(messageID)
          .update({"seen": true});
      //edit for me
      _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(senderID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(reciverUserID)
          .collection(FirebaseConstant.meassageCollection)
          .doc(messageID)
          .update({"seen": true});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void deleteChat(String senderID, String reciverID) async {
    try {
      final result = await _firebaseFirestore
          .collection(FirebaseConstant.usersCollection)
          .doc(senderID)
          .collection(FirebaseConstant.chatsCollection)
          .doc(reciverID)
          .delete();
      result;
    } catch (e) {
      rethrow;
    }
  }
}
