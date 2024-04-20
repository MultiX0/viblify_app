import '../enums/request_type.dart';

class ImageGenerateAiModel {
  final String prompt_id;
  final String userID;
  final String img_url;
  final String body;
  final bool hasError;
  final DateTime createdAt;
  final DateTime response_date;
  final String response;
  final AiRequestType request_type;
  ImageGenerateAiModel({
    required this.prompt_id,
    required this.userID,
    required this.img_url,
    required this.hasError,
    required this.createdAt,
    required this.body,
    required this.response_date,
    required this.request_type,
    required this.response,
  });

  ImageGenerateAiModel copyWith({
    String? prompt_id,
    String? userID,
    String? img_url,
    String? body,
    bool? hasError,
    AiRequestType? request_type,
    DateTime? createdAt,
    DateTime? response_date,
    String? response,
  }) {
    return ImageGenerateAiModel(
      prompt_id: prompt_id ?? this.prompt_id,
      userID: userID ?? this.userID,
      img_url: img_url ?? this.img_url,
      createdAt: createdAt ?? this.createdAt,
      body: body ?? this.body,
      response_date: response_date ?? this.response_date,
      hasError: hasError ?? this.hasError,
      request_type: request_type ?? this.request_type,
      response: response ?? this.response,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'prompt_id': prompt_id,
      'userID': userID,
      'img_url': img_url,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'body': body,
      'response_date': response_date.millisecondsSinceEpoch,
      'hasError': hasError,
      'request_type': getRequestType(request_type),
      'response': '',
    };
  }

  factory ImageGenerateAiModel.fromMap(Map<String, dynamic> map) {
    return ImageGenerateAiModel(
      prompt_id: map['prompt_id'] ?? "",
      userID: map['userID'] ?? "",
      img_url: map['img_url'] ?? "",
      hasError: map['hasError'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      body: map['body'] ?? "",
      response_date: DateTime.fromMillisecondsSinceEpoch(map['response_date'] as int),
      request_type: getRequestTypeFromString(map['request_type'] ?? ""),
      response: map['response'] ?? "",
    );
  }
}
