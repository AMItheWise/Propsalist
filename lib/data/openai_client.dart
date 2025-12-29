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
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/chat/completions',
      data: request.toJson(),
      options: Options(headers: buildHeaders()),
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response body.');
    }

    return OpenAIChatResponse.fromJson(data);
  }
}
