import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:viblify_app/features/dash/controller/dash_controller.dart';

TextEditingController hashTags = TextEditingController();
TextEditingController titleController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class AddNewDash extends ConsumerStatefulWidget {
  final Map<String, dynamic> path;
  const AddNewDash({super.key, required this.path});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNewDashState();
}

class _AddNewDashState extends ConsumerState<AddNewDash> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? validateTitle(String value) {
    if (value.trim().length < 4) {
      return 'The text must be at least 4 characters';
    }
    return null;
  }

  FocusNode focusNode = FocusNode();
  FocusNode titleNode = FocusNode();
  FocusNode descriptionNode = FocusNode();
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _scrollToTextField();
      }
    });
    titleNode.addListener(() {
      if (focusNode.hasFocus) {
        _scrollToTextField();
      }
    });
    descriptionNode.addListener(() {
      if (focusNode.hasFocus) {
        _scrollToTextField();
      }
    });
  }

  void _scrollToTextField() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  List tags = [];
  void addNewTag() {
    String newTag = hashTags.text;
    if (newTag.isEmpty) {
      focusNode.unfocus();
    } else {
      setState(() {
        tags.add(newTag);
        hashTags.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.path['path'] ?? "";

    void addDash() {
      if (_formKey.currentState?.validate() ?? false) {
        ref.watch(dashControllerProvider.notifier).addDash(
            file: File(data),
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            context: context,
            tags: tags,
            isCommentsOpen: true);
        titleController.clear();
        descriptionController.clear();
        tags.clear();
        hashTags.clear();
        log('Form is valid. Title: ${titleController.text}');
      } else {
        log('Form is not valid');
      }
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("add new dash"),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: addDash,
        child: const Icon(Icons.done),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              controller: _scrollController,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(data),
                      width: size.width / 3.5,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  enabled: true,
                  focusNode: titleNode,
                  controller: titleController,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "عنوان",
                    hintText: "هنا..",
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  validator: (val) => validateTitle(val!),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  focusNode: descriptionNode,
                  enabled: true,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "الوصف",
                    hintText: "هنا..",
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  validator: (val) => validateTitle(val!),
                ),
                const SizedBox(
                  height: 25,
                ),
                if (tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                      tags.length,
                      (index) => Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tags[index],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  tags.removeAt(index);
                                });
                              },
                              child: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
                TextField(
                  enabled: true,
                  controller: hashTags,
                  textInputAction: TextInputAction.next,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "الكلمات المفتاحية (هاشتاقز)",
                    hintText: "هنا..",
                    prefixIcon: const Icon(LineIcons.hashtag),
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  onEditingComplete: addNewTag,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
