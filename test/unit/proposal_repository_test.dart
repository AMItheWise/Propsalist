import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';
import 'package:proposal_writer/data/proposal_repository_impl.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';

class FakeOpenAIClient implements OpenAIClient {
  FakeOpenAIClient({this.response, this.error});

  final OpenAIChatResponse? response;
  final Exception? error;

  @override
  Future<OpenAIChatResponse> createChatCompletion(
    OpenAIChatRequest request,
  ) async {
    if (error != null) {
      throw error!;
    }
    return response!;
  }
}

void main() {
  final config = EnvConfig(
    apiKey: 'key',
    model: 'gpt-test',
    baseUrl: Uri.parse('https://api.openai.com'),
    mockApi: false,
  );

  test('ProposalRepositoryImpl returns success with parsed content', () async {
    final client = FakeOpenAIClient(
      response: const OpenAIChatResponse(
        choices: [
          OpenAIChatChoice(
            message: OpenAIChatMessage(role: 'assistant', content: 'Hello'),
          ),
        ],
      ),
    );
    final repository = ProposalRepositoryImpl(client: client, config: config);

    final result = await repository.generateProposal(
      prompt: 'Test',
      tone: ProposalTone.direct,
      maxTokens: 64,
    );

    expect(result, isA<Success<Proposal>>());
    result.when(
      success: (proposal) => expect(proposal.content, 'Hello'),
      failure: (_) => fail('Expected success'),
    );
  });

  test(
    'ProposalRepositoryImpl maps network errors to NetworkFailure',
    () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/v1/chat/completions'),
      );
      final client = FakeOpenAIClient(error: dioError);
      final repository = ProposalRepositoryImpl(client: client, config: config);

      final result = await repository.generateProposal(
        prompt: 'Test',
        tone: ProposalTone.direct,
        maxTokens: 64,
      );

      expect(result, isA<FailureResult<Proposal>>());
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (failure) => expect(failure, isA<NetworkFailure>()),
      );
    },
  );
}
