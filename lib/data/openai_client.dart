import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';

abstract class OpenAIClient {
  Future<OpenAIChatResponse> createChatCompletion(OpenAIChatRequest request);
}

class DioOpenAIClient implements OpenAIClient {
  DioOpenAIClient({required Dio dio, required EnvConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final EnvConfig _config;

  @visibleForTesting
  Map<String, String> buildHeaders() {
    return <String, String>{
      'Authorization': 'Bearer ${_config.apiKey}',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<OpenAIChatResponse> createChatCompletion(
    OpenAIChatRequest request,
  ) async {
    if (_shouldUseResponsesApi(request.model)) {
      return _createResponseCompletion(request);
    }

    _debugLog('OpenAI chat request', {
      'endpoint': '/v1/chat/completions',
      'body': request.toJson(),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/chat/completions',
      data: request.toJson(),
      options: Options(headers: buildHeaders()),
    );

    final data = response.data;
    _debugLog('OpenAI chat response', data);
    if (data == null) {
      throw const FormatException('Empty response body.');
    }

    return OpenAIChatResponse.fromJson(data);
  }

  bool _shouldUseResponsesApi(String model) {
    return model.startsWith('gpt-5');
  }

  Future<OpenAIChatResponse> _createResponseCompletion(
    OpenAIChatRequest request,
  ) async {
    final payload = _buildResponsesRequest(request);
    _debugLog('OpenAI responses request', {
      'endpoint': '/v1/responses',
      'body': payload,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/responses',
      data: payload,
      options: Options(headers: buildHeaders()),
    );

    final data = response.data;
    _debugLog('OpenAI responses response', data);
    if (data == null) {
      throw const FormatException('Empty response body.');
    }

    _throwIfIncomplete(data);
    final content = _extractResponsesText(data);
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('Empty response content.');
    }

    return OpenAIChatResponse(
      choices: [
        OpenAIChatChoice(
          message: OpenAIChatMessage(role: 'assistant', content: content),
        ),
      ],
    );
  }

  Map<String, dynamic> _buildResponsesRequest(OpenAIChatRequest request) {
    return <String, dynamic>{
      'model': request.model,
      'input': request.messages
          .map(
            (message) => <String, dynamic>{
              'role': message.role,
              'content': [
                {
                  'type': 'input_text',
                  'text': message.content,
                },
              ],
            },
          )
          .toList(),
      'max_output_tokens': request.maxTokens,
    };
  }

  String? _extractResponsesText(Map<String, dynamic> data) {
    final outputText = data['output_text'];
    if (outputText is String && outputText.isNotEmpty) {
      return outputText;
    }
    if (outputText is List && outputText.isNotEmpty) {
      final buffer = StringBuffer();
      for (final part in outputText) {
        if (part is String) {
          buffer.write(part);
          continue;
        }
        if (part is Map<String, dynamic> && part['text'] is String) {
          buffer.write(part['text'] as String);
        }
      }
      final text = buffer.toString();
      if (text.isNotEmpty) {
        return text;
      }
    }

    final output = data['output'];
    if (output is! List) {
      return null;
    }

    final buffer = StringBuffer();
    for (final item in output) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final content = item['content'];
      if (content is! List) {
        continue;
      }
      for (final part in content) {
        if (part is! Map<String, dynamic>) {
          continue;
        }
        if (part['type'] == 'output_text' && part['text'] is String) {
          buffer.write(part['text'] as String);
        }
      }
    }

    final text = buffer.toString();
    return text.isEmpty ? null : text;
  }

  void _throwIfIncomplete(Map<String, dynamic> data) {
    final status = data['status'];
    if (status != 'incomplete') {
      return;
    }
    final details = data['incomplete_details'];
    if (details is Map<String, dynamic>) {
      final reason = details['reason'];
      if (reason is String && reason.isNotEmpty) {
        throw FormatException('Response incomplete: $reason.');
      }
    }
    throw const FormatException('Response incomplete.');
  }

  void _debugLog(String label, Object? payload) {
    if (!kDebugMode) {
      return;
    }

    String serialized;
    try {
      serialized = const JsonEncoder.withIndent('  ').convert(payload);
    } catch (_) {
      serialized = payload.toString();
    }
    debugPrint('[$label]\n$serialized');
  }
}
