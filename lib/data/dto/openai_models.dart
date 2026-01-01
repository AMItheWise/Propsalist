import 'package:freezed_annotation/freezed_annotation.dart';

part 'openai_models.freezed.dart';
part 'openai_models.g.dart';

@freezed
abstract class OpenAIChatMessage with _$OpenAIChatMessage {
  const factory OpenAIChatMessage({
    required String role,
    required String content,
  }) = _OpenAIChatMessage;

  factory OpenAIChatMessage.fromJson(Map<String, dynamic> json) =>
      _$OpenAIChatMessageFromJson(json);
}

@freezed
abstract class OpenAIChatRequest with _$OpenAIChatRequest {
  const factory OpenAIChatRequest({
    required String model,
    required List<OpenAIChatMessage> messages,
    @JsonKey(name: 'max_tokens') required int maxTokens,
  }) = _OpenAIChatRequest;

  factory OpenAIChatRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIChatRequestFromJson(json);
}

@freezed
abstract class OpenAIChatChoice with _$OpenAIChatChoice {
  const factory OpenAIChatChoice({required OpenAIChatMessage message}) =
      _OpenAIChatChoice;

  factory OpenAIChatChoice.fromJson(Map<String, dynamic> json) =>
      _$OpenAIChatChoiceFromJson(json);
}

@freezed
abstract class OpenAIChatResponse with _$OpenAIChatResponse {
  const factory OpenAIChatResponse({required List<OpenAIChatChoice> choices}) =
      _OpenAIChatResponse;

  factory OpenAIChatResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIChatResponseFromJson(json);
}
