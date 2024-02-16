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

    final uid = ref.watch(userProvider)!.userID;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My anonymous messages"),
      ),
      body: ref.watch(getAllSttsProvider(uid)).when(
            data: (stts) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: stts.map((stt) {
                      return stt.isShowed != false
                          ? Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 12,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      stt.message,
                                      textDirection: Bidi.hasAnyRtl(stt.message)
                                          ? ui.TextDirection.rtl
                                          : ui.TextDirection.ltr,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => repostTheStt(stt.sttID),
                                      icon: const Icon(Ionicons.repeat),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox();
                    }).toList(),
                  ),
                ),
              );
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
