// ignore_for_file: camel_case_types, depend_on_referenced_packages

import 'dart:developer';
import 'package:path/path.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stability_image_generation/stability_image_generation.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/features/ai/repository/ai_repository.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../enums/request_type.dart';
import '../models/image_generate_ai_model.dart';

final String stability_api_key = dotenv.env['STABILITY_API_KEY'] ?? "";
final String gemeni_api_key = dotenv.env['GOOGLE_GENERATIVE_API_KEY'] ?? "";
final StabilityAI _ai = StabilityAI();

final getUserPromptsProvider = StreamProvider((ref) {
  final myID = ref.read(userProvider)!.userID;
  final aiController = ref.watch(aiControllerProvider.notifier);
  return aiController.getUserPrompts(myID);
});

final getUserPromptCountProvider = StreamProvider<int>((ref) {
  final aiController = ref.watch(aiControllerProvider.notifier);
  final myID = ref.read(userProvider)!.userID;
  return aiController.getUserPromptsCount(myID);
});

final aiControllerProvider = StateNotifierProvider<AiController, bool>((ref) {
  final _repository = ref.watch(aiRepositoryProvider);
  final _storageRepository = ref.watch(firebaseStorageProvider);
  return AiController(repository: _repository, ref: ref, storageRepository: _storageRepository);
});

class AiController extends StateNotifier<bool> {
  final uuid = const Uuid();
  AiRepository _repository;
  final Ref _ref;
  AiController(
      {required AiRepository repository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        super(false);

  Future<void> addPrompt({
    required String body,
    required AiRequestType request_type,
    required ImageGenerateAiModel aiModel,
    required ImageAIStyle imageAIStyle,
  }) async {
    try {
      state = true;

      final uid = _ref.read(userProvider)!.userID;

      _repository.addPrompt(aiModel);
      if (request_type == AiRequestType.image_ai) {
        /// Call the generateImage method with the required parameters.
        Uint8List image = await _ai.generateImage(
          apiKey: stability_api_key,
          imageAIStyle: imageAIStyle,
          prompt: body,
        );

        Uint8List compressedImage = await FlutterImageCompress.compressWithList(
          image,
          quality: 70,
        );

        FirebaseStorage storage = FirebaseStorage.instance;

        Reference storageRef =
            storage.ref().child('prompts/$uid/${basename("${aiModel.prompt_id}.jpg")}');
        UploadTask uploadTask = storageRef.putData(compressedImage);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        _repository.addImageToThePrompt(aiModel.prompt_id, downloadURL);
        state = false;
      } else {
        final model = GenerativeModel(model: 'gemini-pro', apiKey: gemeni_api_key);
        final content = [Content.text(body)];
        final response = await model.generateContent(content);
        _repository.addResponseToThePrompt(aiModel.prompt_id, response.text!);
        state = false;
      }
    } catch (e) {
      _repository.hasError(aiModel.prompt_id);
      state = false;
      log(e.toString());
      throw Failure(e.toString());
    }
  }

  Stream<List<ImageGenerateAiModel>> getUserPrompts(String userID) {
    return _repository.getUserPrompts(userID);
  }

  Stream<int> getUserPromptsCount(String userID) {
    return _repository.getUserPromptsCount(userID);
  }
}
