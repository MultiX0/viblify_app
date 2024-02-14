// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/Constant/constant.dart';
import 'package:viblify_app/core/common/error_text.dart';
import 'package:viblify_app/core/common/loader.dart';
import 'package:viblify_app/core/utils.dart';
import 'package:viblify_app/features/community/controller/community_controller.dart';
import 'package:viblify_app/models/community_model.dart';
import 'package:viblify_app/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;
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
      setState(() {
        avatarFile = File(result.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communitControllerProvider.notifier).editCommunity(
        profileFile: avatarFile,
        communityBanner: bannerFile,
        context: context,
        community: community);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communitControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => Scaffold(
              appBar: AppBar(
                backgroundColor:
                    Pallete.darkModeAppTheme.colorScheme.background,
                title: const Text("Edit Community"),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () => save(community),
                    child: isLoading
                        ? const SizedBox(
                            height: 15,
                            width: 15,
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
                              color: Pallete
                                  .darkModeAppTheme.textTheme.bodyText2!.color!,
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
                                    : community.banner.isEmpty ||
                                            community.banner ==
                                                Constant.bannerDefault
                                        ? const Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                            ),
                                          )
                                        : Image.network(
                                            community.banner,
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
                                      backgroundImage:
                                          NetworkImage(community.avatar),
                                      radius: 32,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        error: (error, trace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
