import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_mock_client.dart';

void main() {
  test('MockOpenAIClient returns deterministic response', () async {
    final config = EnvConfig(
      apiKey: '',
      model: 'gpt-mock',
      baseUrl: Uri.parse('https://api.openai.com'),
      mockApi: true,
    );
    final client = MockOpenAIClient(config: config);

    final response = await client.createChatCompletion(
      const OpenAIChatRequest(
        model: 'gpt-mock',
        maxTokens: 128,
        messages: [
          OpenAIChatMessage(role: 'system', content: 'system'),
          OpenAIChatMessage(role: 'user', content: 'Write a proposal'),
        ],
      ),
    );

    expect(
      response.choices.first.message.content,
      contains('[MOCK] gpt-mock: Write a proposal'),
    );
  });
}
