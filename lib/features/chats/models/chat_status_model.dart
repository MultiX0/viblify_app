class ChatStatus {
  final bool sentByMe;
  final bool lastMessageSeen;
  final int unseenMessagesCount;

  ChatStatus(
      {required this.sentByMe,
      required this.lastMessageSeen,
      required this.unseenMessagesCount});
}
