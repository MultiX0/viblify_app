// ignore_for_file: unused_result

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/community/controller/community_controller.dart';

import '../../../responsive/responsive.dart';

class CreateComunityScreen extends ConsumerStatefulWidget {
  const CreateComunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateComunityScreenState();
}

class _CreateComunityScreenState extends ConsumerState<CreateComunityScreen> {
  final allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789_';

  final communityNameController = TextEditingController();
  String communityName = '';
  bool length = false;
  void check() {}

  @override
  Widget build(BuildContext context) {
    final isNameAccepted = ref.watch(communityNameTakenProvider(communityName));

    final bool check = isNameAccepted.maybeWhen(
      data: (boolValue) => boolValue, // Use a default value if null
      orElse: () => false, // Handle other cases (loading, error)
    );
    final bool isUsernameTaken = !check;
    void createCommunity() {
      if (!length) {
        if (isUsernameTaken) {
          ref.read(communitControllerProvider.notifier).createCommunity(communityName, context);
        } else {
          showSnackBar(context, "The Name is Already used");
        }
      }
    }

    final isLoading = ref.watch(communitControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create a Community"),
      ),
      body: Responsive(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Community name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: communityNameController,
                onChanged: (val) {
                  setState(() {
                    communityName = val;
                  });
                  if (communityName.length <= 3) {
                    setState(() {
                      length = true;
                    });
                  } else {
                    setState(() {
                      length = false;
                    });
                  }
                  ref.refresh(communityNameTakenProvider(communityName));
                  log("refreshed");
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[$allowedChars]')),
                ],
                decoration: InputDecoration(
                  errorText: !isUsernameTaken
                      ? "Username is not available"
                      : length
                          ? "the minimum name should be 4 chars"
                          : null,
                  hintText: 'Community name',
                  filled: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
                maxLength: 21,
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: createCommunity,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Create community',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
