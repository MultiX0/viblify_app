// ignore_for_file: void_checks, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viblify_app/core/failure.dart';
import 'package:viblify_app/core/providers/firebase_providers.dart';
import 'package:viblify_app/features/ai/models/image_generate_ai_model.dart';

import '../../../../core/Constant/firebase_constant.dart';
import '../../../../core/type_defs.dart';

final aiRepositoryProvider = Provider((ref) {
  return AiRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class AiRepository {
  final supabase = Supabase.instance.client;
  AiRepository({required FirebaseFirestore firebaseFirestore});

  SupabaseQueryBuilder get _ai_prompt => supabase.from(FirebaseConstant.ai_promptCollection);
  FutureVoid addPrompt(ImageGenerateAiModel prompt) async {
    try {
      return right(await _ai_prompt.insert(prompt.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ImageGenerateAiModel>> getUserPrompts(String userID) {
    var stream = _ai_prompt
        .stream(primaryKey: ['prompt_id'])
        .eq("userID", userID)
        .order('createdAt', ascending: false)
        .map((data) {
          List<ImageGenerateAiModel> prompts = [];
          data.forEach((prompt) => prompts.add(ImageGenerateAiModel.fromMap(prompt)));
          return prompts;
        });

    return stream;
  }

  Stream<int> getUserPromptsCount(String userID) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return _ai_prompt
        .stream(primaryKey: ['prompt_id'])
        .gt("createdAt", yesterday.millisecondsSinceEpoch)
        .order('createdAt', ascending: false)
        .map((data) {
          List<Map<String, dynamic>> list = [];
          for (var prompt in data) {
            if (prompt['userID'] == userID) {
              list.add(prompt);
            }
          }
          // Return the count of filtered prompts
          return list.length;
        });
  }

  Future<void> editPrompt(String promptID, String img_url) async {
    try {
      final response_date = DateTime.now().millisecondsSinceEpoch;
      await _ai_prompt
          .update({'img_url': img_url, "response_date": response_date}).eq("prompt_id", promptID);
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }

  Future<void> hasError(String promptID) async {
    try {
      await _ai_prompt.update({"hasError": true}).eq("prompt_id", promptID);
    } catch (e) {
      log(e.toString());
      throw Failure(e.toString());
    }
  }
}
