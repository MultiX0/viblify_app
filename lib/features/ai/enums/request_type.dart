enum AiRequestType { image_ai, text_ai }

String getRequestType(AiRequestType request) {
  switch (request) {
    case AiRequestType.image_ai:
      return "image_ai";
    case AiRequestType.text_ai:
      return "text_ai";
    default:
      return "image_ai";
  }
}

AiRequestType getRequestTypeFromString(String request_type) {
  switch (request_type) {
    case "image_ai":
      return AiRequestType.image_ai;
    case "text_ai":
      return AiRequestType.text_ai;
    default:
      return AiRequestType.image_ai;
  }
}
