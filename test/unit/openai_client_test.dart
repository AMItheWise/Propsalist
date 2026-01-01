import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastData = options.data;

    const response = OpenAIChatResponse(
      choices: [
        OpenAIChatChoice(
          message: OpenAIChatMessage(role: 'assistant', content: 'ok'),
        ),
      ],
    );

    return ResponseBody.fromString(
      jsonEncode(response.toJson()),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'DioOpenAIClient builds request with headers, endpoint, and body',
    () async {
      final adapter = RecordingAdapter();
      final config = EnvConfig(
        apiKey: 'test-key',
        model: 'gpt-test',
        baseUrl: Uri.parse('https://api.openai.com'),
        mockApi: false,
      );
      final dio = Dio(BaseOptions(baseUrl: config.baseUrl.toString()))
        ..httpClientAdapter = adapter;
      final client = DioOpenAIClient(dio: dio, config: config);

      const request = OpenAIChatRequest(
        model: 'gpt-test',
        maxTokens: 120,
        messages: [
          OpenAIChatMessage(role: 'system', content: 'system'),
          OpenAIChatMessage(role: 'user', content: 'prompt'),
        ],
      );

      await client.createChatCompletion(request);

      expect(adapter.lastRequest?.path, '/v1/chat/completions');
      expect(adapter.lastRequest?.headers['Authorization'], 'Bearer test-key');
      expect(adapter.lastRequest?.headers['Content-Type'], 'application/json');
      expect(adapter.lastData, request.toJson());
    },
  );
}
