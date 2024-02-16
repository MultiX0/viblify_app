// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';
import 'dart:ui' as ui;
import 'package:viblify_app/features/stt/controller/stt_controller.dart';

TextEditingController contentController = TextEditingController();

class MySttScreen extends ConsumerStatefulWidget {
  const MySttScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MySttScreenState();
}

class _MySttScreenState extends ConsumerState<MySttScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    void repostTheStt(String sttID) {
      showModalBottomSheet(
          isScrollControlled: false,
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: _scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      const Text('اضف عنوان المنشور'),
                      IconButton(
                        onPressed: () async {
                          if (contentController.text.trim().length >= 8) {
                            ref.watch(postControllerProvider.notifier).addPost(
                                image: null,
                                gif: '',
                                sttID: sttID,
                                content: contentController.text.trim(),
                                videoID: '',
                                context: context,
                                tags: [],
                                isCommentsOpen: true);
                            contentController.clear();
                          } else {
                            Fluttertoast.showToast(
                                msg: "على المنشور أن يحتوي على 8 أحرف أو أكثر");
                          }
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  ),
                  TextField(
                    controller: contentController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "اكتب هنا",
                      hintStyle: TextStyle(
                        color: Colors.grey[600]!,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue[800]!, width: 1.5),
                      ),
                      enabled: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[900]!),
                      ),
                    ),
                    textDirection: Bidi.hasAnyRtl(contentController.text)
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                  ),
                ],
              ),
            );
          });
    }

    void deleteStt(String sttID) {
      showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("هل تريد حذف الاعتراف؟"),
            content: const Text(
                "هل أنت متأكد من رغبتك في حذف هذا الاعتراف , مع العلم أن قرار الحذف نهائي ولا يتم الرجوع فيه"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("رجوع"),
              ),
              TextButton(
                onPressed: () {
                  final myID = ref.read(userProvider)!.userID;
                  Navigator.of(context).pop();
                  ref
                      .watch(sttControllerProvider.notifier)
                      .deleteStt(myID, sttID);
                  Fluttertoast.showToast(msg: 'تمت العملية بنجاح');
                },
                child: const Text("تأكيد"),
              ),
            ],
          );
        }),
      );
    }

    final uid = ref.watch(userProvider)!.userID;

    return WillPopScope(
      onWillPop: () async {
        contentController.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("My anonymous messages"),
        ),
        body: ref.watch(getAllSttsProvider(uid)).when(
              data: (stts) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    itemCount: stts.length,
                    itemBuilder: (context, index) {
                      final stt = stts[index];

                      return Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stt.message,
                                  textDirection: Bidi.hasAnyRtl(stt.message)
                                      ? ui.TextDirection.rtl
                                      : ui.TextDirection.ltr,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => repostTheStt(stt.sttID),
                                icon: const Icon(Icons.repeat),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => deleteStt(stt.sttID),
                                icon: const Icon(Ionicons.remove),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, trace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
