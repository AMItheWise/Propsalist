import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.responseBody);

  RequestOptions? lastRequest;
  Object? lastData;
  final String responseBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastData = options.data;

    return ResponseBody.fromString(
      responseBody,
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
      const response = OpenAIChatResponse(
        choices: [
          OpenAIChatChoice(
            message: OpenAIChatMessage(role: 'assistant', content: 'ok'),
          ),
        ],
      );
      final adapter = RecordingAdapter(jsonEncode(response.toJson()));
      final config = EnvConfig(
        apiKey: 'test-key',
        model: 'gpt-test',
        baseUrl: Uri.parse('https://api.openai.com'),
        mockApi: false,
        firebaseOptions: null,
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

  test('DioOpenAIClient uses the responses API for gpt-5 models', () async {
    const responseBody = {
      'output': [
        {
          'type': 'message',
          'role': 'assistant',
          'content': [
            {'type': 'output_text', 'text': 'ok'},
          ],
        },
      ],
    };
    final adapter = RecordingAdapter(jsonEncode(responseBody));
    final config = EnvConfig(
      apiKey: 'test-key',
      model: 'gpt-5-mini',
      baseUrl: Uri.parse('https://api.openai.com'),
      mockApi: false,
      firebaseOptions: null,
    );
    final dio = Dio(BaseOptions(baseUrl: config.baseUrl.toString()))
      ..httpClientAdapter = adapter;
    final client = DioOpenAIClient(dio: dio, config: config);

    const request = OpenAIChatRequest(
      model: 'gpt-5-mini',
      maxTokens: 120,
      messages: [
        OpenAIChatMessage(role: 'system', content: 'system'),
        OpenAIChatMessage(role: 'user', content: 'prompt'),
      ],
    );

    await client.createChatCompletion(request);

    expect(adapter.lastRequest?.path, '/v1/responses');
    expect(adapter.lastData, {
      'model': 'gpt-5-mini',
      'input': [
        {
          'role': 'system',
          'content': [
            {'type': 'input_text', 'text': 'system'},
          ],
        },
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'prompt'},
          ],
        },
      ],
      'max_output_tokens': 120,
    });
  });

  test('DioOpenAIClient handles output_text list of objects', () async {
    const responseBody = {
      'output_text': [
        {'type': 'output_text', 'text': 'ok'},
      ],
    };
    final adapter = RecordingAdapter(jsonEncode(responseBody));
    final config = EnvConfig(
      apiKey: 'test-key',
      model: 'gpt-5-mini',
      baseUrl: Uri.parse('https://api.openai.com'),
      mockApi: false,
      firebaseOptions: null,
    );
    final dio = Dio(BaseOptions(baseUrl: config.baseUrl.toString()))
      ..httpClientAdapter = adapter;
    final client = DioOpenAIClient(dio: dio, config: config);

    const request = OpenAIChatRequest(
      model: 'gpt-5-mini',
      maxTokens: 120,
      messages: [
        OpenAIChatMessage(role: 'system', content: 'system'),
        OpenAIChatMessage(role: 'user', content: 'prompt'),
      ],
    );

    final response = await client.createChatCompletion(request);

    expect(response.choices.first.message.content, 'ok');
  });

  test('DioOpenAIClient surfaces incomplete responses', () async {
    const responseBody = <String, Object?>{
      'status': 'incomplete',
      'incomplete_details': <String, Object?>{'reason': 'max_output_tokens'},
      'output': <Object?>[],
    };
    final adapter = RecordingAdapter(jsonEncode(responseBody));
    final config = EnvConfig(
      apiKey: 'test-key',
      model: 'gpt-5-mini',
      baseUrl: Uri.parse('https://api.openai.com'),
      mockApi: false,
      firebaseOptions: null,
    );
    final dio = Dio(BaseOptions(baseUrl: config.baseUrl.toString()))
      ..httpClientAdapter = adapter;
    final client = DioOpenAIClient(dio: dio, config: config);

    const request = OpenAIChatRequest(
      model: 'gpt-5-mini',
      maxTokens: 120,
      messages: [
        OpenAIChatMessage(role: 'system', content: 'system'),
        OpenAIChatMessage(role: 'user', content: 'prompt'),
      ],
    );

    expect(
      () => client.createChatCompletion(request),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Response incomplete: max_output_tokens.',
        ),
      ),
    );
  });
}
