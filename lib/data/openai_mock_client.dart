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
    final model = _config.model.isNotEmpty ? _config.model : request.model;
    final content = '[MOCK] $model: $prompt';

    return OpenAIChatResponse(
      choices: [
        OpenAIChatChoice(
          message: OpenAIChatMessage(role: 'assistant', content: content),
        ),
      ],
    );
  }
}
