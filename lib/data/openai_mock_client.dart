import 'dart:convert';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';

class MockOpenAIClient implements OpenAIClient {
  MockOpenAIClient({required EnvConfig config}) : _config = config;

  final EnvConfig _config;

  @override
  Future<OpenAIChatResponse> createChatCompletion(
    OpenAIChatRequest request,
  ) async {
    final prompt = request.messages.isNotEmpty
        ? request.messages.last.content
        : '';
    final systemPrompt = request.messages.isNotEmpty
        ? request.messages.first.content
        : '';
    final model = _config.model.isNotEmpty ? _config.model : request.model;
    final content = systemPrompt.contains(clarificationPrompt)
        ? jsonEncode({
            'needs_clarification': false,
            'questions': <String>[],
            'summary': 'Mocked summary of the request.',
            'improved_prompt': 'Mocked improved prompt.',
          })
        : '[MOCK] $model: $prompt';

    return OpenAIChatResponse(
      choices: [
        OpenAIChatChoice(
          message: OpenAIChatMessage(role: 'assistant', content: content),
        ),
      ],
    );
  }
}
