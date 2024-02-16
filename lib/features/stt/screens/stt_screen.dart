// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:viblify_app/features/stt/controller/stt_controller.dart';
import 'package:viblify_app/theme/pallete.dart';
import 'dart:ui' as ui;

TextEditingController sttController = TextEditingController();

class SayTheTruth extends ConsumerStatefulWidget {
  final String userID;
  final String useraName;
  const SayTheTruth({super.key, required this.userID, required this.useraName});

  @override
  ConsumerState<SayTheTruth> createState() => _SayTheTruthState();
}

class _SayTheTruthState extends ConsumerState<SayTheTruth> {
  @override
  Widget build(BuildContext context) {
    void addStt() {
      if (sttController.text.trim().length >= 8) {
        ref.watch(sttControllerProvider.notifier).addStt(
            message: sttController.text.trim(),
            userID: widget.userID,
            context: context);
        sttController.clear();
      } else {
        Fluttertoast.showToast(
            msg: "على الرسالة ان تحتوي على الأقل على 8 أحرف");
      }
    }

    void about() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("stt (say the truth)"),
              content: const Text(
                  'It’s a fresh take on anonymity. We believe anonymity should be a fun yet safe place to express your feelings and opinions without shame. Young people don’t have a space to share their feelings without judgement from friends or societal pressures. Stt provides this safe space for teens. \n\n إنها طريقة جديدة لعدم الكشف عن هويتك. نحن نؤمن بأن عدم الكشف عن هويتك يجب أن يكون مكانًا ممتعًا وآمنًا للتعبير عن مشاعرك وآرائك دون خجل. ليس لدى الشباب مساحة لمشاركة مشاعرهم دون الحكم من الأصدقاء أو الضغوط المجتمعية. توفر Stt هذه المساحة الآمنة للمراهقين.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('فهمت'),
                )
              ],
            );
          });
    }

    final width = MediaQuery.of(context).size.width;
    bool isArabic = Bidi.hasAnyRtl(sttController.text);

    return WillPopScope(
      onWillPop: () async {
        sttController.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            "Add New Anonymous",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          actions: [
            IconButton(
              onPressed: about,
              icon: const Icon(Icons.info_outline),
            )
          ],
          toolbarHeight: kToolbarHeight + 15,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(35),
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: Pallete.redColor.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                            child: Text(
                          "anonymous message to  @${widget.useraName}  here",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    Container(
                      width: width,
                      decoration: const BoxDecoration(
                        color: Pallete.greyColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        controller: sttController,
                        onChanged: (val) {
                          setState(() {
                            isArabic = Bidi.hasAnyRtl(sttController.text);
                          });
                        },
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        maxLength: 300,
                        decoration: InputDecoration(
                          counterStyle: const TextStyle(color: Colors.white),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: 'here....',
                          hintStyle: TextStyle(color: Colors.grey[500]!),
                        ),
                        textDirection: isArabic
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: addStt,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Pallete.redColor.withOpacity(0.5),
                        ),
                        child: const Text(
                          "Done",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
