// ignore_for_file: unused_result

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:string_validator/string_validator.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:viblify_app/features/auth/models/user_model.dart';

import '../../../core/Constant/constant.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  bool stt = false;
  String currentVal = 'Prefer not to say';
  List<String> mbtis = [
    "Prefer not to say",
    "ISTJ",
    "ISFJ",
    "INFJ",
    "INTJ",
    "ISTP",
    "ISFP",
    "INFP",
    "INTP",
    "ESTP",
    "ESFP",
    "ENFP",
    "ENTP",
    "ESTJ",
    "ESFJ",
    "ENFJ",
    "ENTJ",
  ];

  String userName = "";
  String link = "";
  bool correctLink = true;
  File? bannerFile;
  File? avatarFile;
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController userNameController;
  late TextEditingController locationController;
  late TextEditingController linkController;
  @override
  void initState() {
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    bioController = TextEditingController(text: ref.read(userProvider)!.bio);
    userNameController = TextEditingController(text: ref.read(userProvider)!.userName);
    locationController = TextEditingController(text: ref.read(userProvider)!.location);
    linkController = TextEditingController(text: ref.read(userProvider)!.link);
    setState(() {
      userName = userNameController.text;
      stt = ref.read(userProvider)!.stt;
      currentVal = ref.read(userProvider)!.mbti;
      currentVal = currentVal.isEmpty ? "Prefer not to say" : currentVal;
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    userNameController.dispose();
    locationController.dispose();
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUsernameAccepted = ref.watch(usernameTakenProvider(userName));
    final bool isUsernameTaken = isUsernameAccepted.maybeWhen(
      data: (boolValue) => boolValue, // Use a default value if null
      orElse: () => false, // Handle other cases (loading, error)
    );
    final isLoading = ref.watch(userProfileControllerProvider);

    void selectBannerImage() async {
      final result = await pickImage();

      if (result != null) {
        setState(() {
          bannerFile = File(result.files.first.path!);
        });
      }
    }

    void selectCommunityImage() async {
      final result = await pickImage();

      if (result != null) {
        File? img = await cropImage(File(result.files.first.path!));
        setState(() {
          avatarFile = img;
        });
      }
    }

    void save(UserModel userModel) {
      ref.read(userProfileControllerProvider.notifier).editProfileUser(
          profileFile: avatarFile,
          banner: bannerFile,
          userName: userName,
          link: linkController.text,
          stt: stt,
          mbti: currentVal == "Prefer not to say" ? '' : currentVal,
          context: context,
          location: locationController.text.trim(),
          name: nameController.text.trim(),
          bio: bioController.text.trim());
    }

    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
              appBar: AppBar(
                backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
                title: const Text("Edit Profile"),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () {
                      if ((isUsernameTaken != false && userName.length >= 4) && (correctLink)) {
                        save(user);
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            "save",
                          ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color: Pallete.darkModeAppTheme.textTheme.bodyMedium!.color!,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: bannerFile != null
                                      ? Image.file(
                                          bannerFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : user.bannerPic.isEmpty ||
                                              user.bannerPic == Constant.bannerDefault
                                          ? const Center(
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                              ),
                                            )
                                          : Image.network(
                                              user.bannerPic,
                                              fit: BoxFit.cover,
                                            ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectCommunityImage,
                                child: avatarFile != null
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(avatarFile!),
                                        radius: 32,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(user.profilePic),
                                        radius: 32,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextField(
                        maxLength: 32,
                        controller: nameController,
                        decoration: InputDecoration(
                          label: const Text("full name"),
                          filled: true,
                          hintText: "name",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 25,
                        controller: userNameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp('[$allowedChars]'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            userName = value;
                          });
                          ref.refresh(usernameTakenProvider(value));
                        },
                        decoration: InputDecoration(
                          label: const Text("user name"),
                          prefixIcon: const Icon(Ionicons.at),
                          filled: true,
                          hintText: "username",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade900,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade900,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: !isUsernameTaken
                              ? "Username is not available"
                              : userName.length <= 3
                                  ? "the minimum name should be 4 chars"
                                  : null,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        maxLength: 155,
                        controller: bioController,
                        enableInteractiveSelection: true, // Add this line
                        decoration: InputDecoration(
                          label: const Text("bio info"),
                          filled: true,
                          hintText: "enter your bio here...",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 32,
                        controller: locationController,
                        decoration: InputDecoration(
                          label: const Text("location"),
                          filled: true,
                          hintText: "location",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextField(
                        controller: linkController,
                        onChanged: (val) {
                          setState(() {
                            link = val;
                            if (link.isNotEmpty) {
                              setState(() {
                                correctLink = isURL(link);
                              });
                            } else if (link.isEmpty) {
                              setState(() {
                                correctLink = true;
                              });
                            }
                          });
                        },
                        enableInteractiveSelection: true, // Add this line

                        decoration: InputDecoration(
                          label: const Text("add one link"),
                          filled: true,
                          hintText: "Link here ...",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade900,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade900,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: !correctLink ? "please enter correct url" : null,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your Personality Types (optionally)'),
                            DropdownButton(
                              value: currentVal,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: mbtis.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  currentVal = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "new feature stt (say the truth) ",
                            ),
                            Switch(
                              value: stt,
                              activeColor: Colors.blue[800],
                              onChanged: (bool value) {
                                setState(() {
                                  stt = !stt;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        error: (error, trace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
