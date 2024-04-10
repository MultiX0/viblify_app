// ignore_for_file: unused_field, prefer_final_fields, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/Constant/firebase_constant.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/chats/repository/chats_repository.dart';
import 'package:viblify_app/models/chat_room_status.dart';
import 'package:viblify_app/models/chats_model.dart';
import 'package:viblify_app/models/message_model.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../messaging/apis.dart';
import '../../../models/chat_status_model.dart';
import '../../../models/user_model.dart';

final getAllMessagesProvider = StreamProvider.family((ref, String chatID) {
  final commentsController = ref.watch(chatsControllerProvider.notifier);
  final userID = ref.read(userProvider)!.userID;
  return commentsController.getAllMessages(chatID, userID);
});
final deleteChatProvider = Provider.family((ref, String reciverID) {
  final chatController = ref.watch(chatsControllerProvider.notifier);
  final myID = ref.read(userProvider)!.userID;

  return chatController.deleteChat(myID, reciverID);
});
final getMembersStatus = StreamProvider.family((ref, String reciver) {
  final commentsController = ref.watch(chatsControllerProvider.notifier);
  final sender = ref.read(userProvider)!.userID;
  return commentsController.memberStatusStream(sender, reciver);
});
final getAllChatRooms = StreamProvider.family((ref, String userID) {
  final commentsController = ref.watch(chatsControllerProvider.notifier);
  return commentsController.getAllInboxMessages(userID);
});
final getChatRoomByID = StreamProvider.family((ref, String targetID) {
  final commentsController = ref.watch(chatsControllerProvider.notifier);
  final myID = ref.read(userProvider)!.userID;
  return commentsController.getChatByID(myID, targetID);
});
final getChatStatus = StreamProvider.family((ref, Tuple2 tuple2) {
  final commentsController = ref.watch(chatsControllerProvider.notifier);
  return commentsController.chatStatusStream(tuple2.item1, tuple2.item2);
});
final chatsControllerProvider = StateNotifierProvider<ChatsController, bool>((ref) {
  final _repository = ref.watch(chatsRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return ChatsController(repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class ChatsController extends StateNotifier<bool> {
  ChatsRepository _repository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  ChatsController(
      {required ChatsRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  var uuid = const Uuid();
  Future<ChatModel?> getChatRoom(
      UserModel userModel, UserModel targetUser, BuildContext context) async {
    ChatModel chatModel = ChatModel();

    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc(userModel.userID)
        .collection(FirebaseConstant.chatsCollection)
        .get();
    if (snapshot.docs.isNotEmpty) {
      chatModel = ChatModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      log("isAvailable");
    }
    return _repository.getChatRoom(userModel, targetUser, chatModel).then(
          (value) => context.push("/chat/${targetUser.userID}/${chatModel.id ?? ""}"),
        );
  }

  Future<MessageModel?> sendMessage(
      {required String chatID,
      required String sender,
      required String reciver,
      required UserModel targetUser,
      required UserModel myData,
      required String content,
      required bool inTheChat,
      required File? image,
      required String? gif,
      required MessageModel? replieMessage,
      required BuildContext context}) async {
    String msg = content.isNotEmpty ? encrypt(content, encryptKey) : content;
    MessageModel messageModel = MessageModel(
        messageid: uuid.v1(),
        sender: sender,
        seen: false,
        replieMessage: replieMessage,
        link: containsUrl(content) ? extractUrls(content)[0] : "",
        gif: gif,
        createdAt: Timestamp.now(),
        text: msg);
    state = true;
    if (image != null) {
      Fluttertoast.showToast(msg: "جاري الارسال");

      final res = await _storageRepository.storeFile(
        path: 'inbox/${messageModel.messageid}',
        id: uuid.v4(),
        file: image,
      );
      res.fold(
        (l) {
          showSnackBar(context, l.message);
          Fluttertoast.showToast(msg: "حدث خطأ أثناء ارسال الصورة ");
        },
        (r) {
          messageModel = messageModel.copyWith(photoUrl: r);
          Fluttertoast.showToast(msg: "تم ارسال الصورة بنجاح");
        },
      );
    }

    return _repository.sendMessage(reciver, sender, messageModel).then((value) {
      // if (inTheChat == false) {

      // }
      APIS.pushNotification(myData, targetUser, image != null ? "image" : content, chatID);
      log(myData.notificationsToken);
      return null;
    });
  }

  Stream<List<MessageModel>> getAllMessages(String chatID, String userID) {
    return _repository.getAllMessages(chatID, userID);
  }

  Stream<List<ChatModel>> getAllInboxMessages(String uid) {
    return _repository.getAllInboxMessages(uid);
  }

  Stream<ChatModel> getChatByID(String myID, String targetID) {
    return _repository.getChatByID(myID, targetID);
  }

  Stream<ChatStatus> chatStatusStream(String chatId, String myUserId) {
    return _repository.chatStatusStream(chatId, myUserId);
  }

  Stream<StatusRoomModel> memberStatusStream(String sender, String reciver) {
    return _repository.memberStatusStream(sender, reciver);
  }

  void setChatMessageSeen(
    BuildContext context,
    String reciverUserID,
    String senderID,
    String messageID,
    String chatID,
  ) {
    _repository.setChatMessageSeen(context, reciverUserID, senderID, messageID, chatID);
  }

  void deleteChat(String senderID, String reciverID) {
    _repository.deleteChat(senderID, reciverID);
  }
}
