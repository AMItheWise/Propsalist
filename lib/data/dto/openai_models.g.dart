// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpenAIChatMessage _$OpenAIChatMessageFromJson(Map<String, dynamic> json) =>
    _OpenAIChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$OpenAIChatMessageToJson(_OpenAIChatMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

_OpenAIChatRequest _$OpenAIChatRequestFromJson(Map<String, dynamic> json) =>
    _OpenAIChatRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => OpenAIChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxTokens: (json['max_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$OpenAIChatRequestToJson(_OpenAIChatRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'max_tokens': instance.maxTokens,
    };

_OpenAIChatChoice _$OpenAIChatChoiceFromJson(Map<String, dynamic> json) =>
    _OpenAIChatChoice(
      message: OpenAIChatMessage.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OpenAIChatChoiceToJson(_OpenAIChatChoice instance) =>
    <String, dynamic>{'message': instance.message};

_OpenAIChatResponse _$OpenAIChatResponseFromJson(Map<String, dynamic> json) =>
    _OpenAIChatResponse(
      choices: (json['choices'] as List<dynamic>)
          .map((e) => OpenAIChatChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OpenAIChatResponseToJson(_OpenAIChatResponse instance) =>
    <String, dynamic>{'choices': instance.choices};
