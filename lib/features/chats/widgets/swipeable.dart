import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MySwipeWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback callback;

  const MySwipeWidget({Key? key, required this.child, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (data) => callback(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: child,
    );
  }
}

class MyReply extends StatelessWidget {
  final bool isMe;
  final Widget child;
  final VoidCallback callback;

  const MyReply({Key? key, required this.child, required this.callback, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey(0),
      direction: isMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
      confirmDismiss: (a) async {
        print("Swiped to the end!");
        callback();
        return null;
      },
      background: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(left: isMe ? 0 : 20, right: isMe ? 20 : 0),
          child: const Icon(
            Icons.replay_rounded,
            color: Colors.white,
          ),
        ),
      ),
      child: child,
    );
  }
}
