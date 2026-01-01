import 'package:dio/dio.dart';

import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';

class ProposalRepositoryImpl implements ProposalRepository {
  ProposalRepositoryImpl({
    required OpenAIClient client,
    required EnvConfig config,
  }) : _client = client,
       _config = config;

  final OpenAIClient _client;
  final EnvConfig _config;

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) async {
    try {
      final request = OpenAIChatRequest(
        model: _config.model,
        maxTokens: maxTokens,
        messages: [
          OpenAIChatMessage(role: 'system', content: tone.systemPrompt),
          OpenAIChatMessage(role: 'user', content: prompt),
        ],
      );

      final response = await _client.createChatCompletion(request);
      if (response.choices.isEmpty) {
        return const FailureResult(
          ParsingFailure('No choices returned from the API.'),
        );
      }

      final content = response.choices.first.message.content.trim();
      if (content.isEmpty) {
        return const FailureResult(
          ParsingFailure('Empty proposal content returned from the API.'),
        );
      }

      return Success(Proposal(content: content));
    } on DioException catch (error) {
      return FailureResult(
        NetworkFailure('Failed to reach the OpenAI API.', cause: error),
      );
    } on FormatException catch (error) {
      return FailureResult(
        ParsingFailure('Failed to parse OpenAI response.', cause: error),
      );
    } catch (error) {
      return FailureResult(
        UnknownFailure('Unexpected error generating proposal.', cause: error),
      );
    }
  }
}
