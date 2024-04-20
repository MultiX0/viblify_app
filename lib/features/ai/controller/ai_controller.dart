// ignore_for_file: camel_case_types, depend_on_referenced_packages

import 'dart:developer';
import 'package:path/path.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stability_image_generation/stability_image_generation.dart';
import 'package:uuid/uuid.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/features/ai/repository/ai_repository.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../models/image_generate_ai_model.dart';

final String apiKey = dotenv.env['STABILITY_API_KEY'] ?? "";
final StabilityAI _ai = StabilityAI();
const ImageAIStyle imageAIStyle = ImageAIStyle.anime;

final getUserPromptsProvider = StreamProvider((ref) {
  final myID = ref.read(userProvider)!.userID;
  final aiController = ref.watch(aiControllerProvider.notifier);
  return aiController.getUserPrompts(myID);
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
  }) async {
    try {
      state = true;

      final uid = _ref.read(userProvider)!.userID;
      final prompt_id = uuid.v4();

      ImageGenerateAiModel aiModel = ImageGenerateAiModel(
        prompt_id: prompt_id,
        userID: uid,
        img_url: "",
        createdAt: DateTime.now(),
        response_date: DateTime.now(),
        body: body,
      );
      _repository.addPrompt(aiModel);

      /// Call the generateImage method with the required parameters.
      Uint8List image = await _ai.generateImage(
        apiKey: apiKey,
        imageAIStyle: imageAIStyle,
        prompt: body,
      );

      FirebaseStorage storage = FirebaseStorage.instance;

      Reference storageRef = storage.ref().child('prompts/$uid/${basename("$prompt_id.jpg")}');
      UploadTask uploadTask = storageRef.putData(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      _repository.editPrompt(prompt_id, downloadURL);
      state = false;
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }

  Stream<List<ImageGenerateAiModel>> getUserPrompts(String userID) {
    return _repository.getUserPrompts(userID);
  }
}
