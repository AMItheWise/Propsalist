import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/dto/openai_models.dart';
import 'package:proposal_writer/data/openai_client.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
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
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
    try {
      final userContext = StringBuffer();
      if (userProfileContext != null && userProfileContext.trim().isNotEmpty) {
        userContext
          ..writeln('Saved user profile:')
          ..writeln(userProfileContext.trim())
          ..writeln();
      }
      userContext.writeln('User request: $prompt');

      final request = OpenAIChatRequest(
        model: _config.model,
        maxTokens: maxTokensLimit,
        messages: [
          const OpenAIChatMessage(role: 'system', content: clarificationPrompt),
          OpenAIChatMessage(role: 'user', content: userContext.toString()),
        ],
      );

      final response = await _client.createChatCompletion(request);
      if (response.choices.isEmpty) {
        return const FailureResult(
          ParsingFailure('No choices returned from the API.'),
        );
      }

      final content = response.choices.first.message.content.trim();
      final payload = _parseClarificationPayload(content);
      if (payload == null) {
        return const FailureResult(
          ParsingFailure('Clarification response was not valid JSON.'),
        );
      }

      final needsClarification =
          payload['needs_clarification'] == true ||
          payload['needsClarification'] == true;
      final questions = (payload['questions'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList();
      final summary = (payload['summary'] as String?)?.trim() ?? '';
      final improvedPrompt =
          (payload['improved_prompt'] as String?)?.trim() ?? '';
      if (summary.isEmpty) {
        return const FailureResult(
          ParsingFailure('Clarification summary was empty.'),
        );
      }
      if (!needsClarification && improvedPrompt.isEmpty) {
        return const FailureResult(
          ParsingFailure('Clarification improved prompt was empty.'),
        );
      }

      return Success(
        ClarificationResponse(
          needsClarification: needsClarification,
          questions: questions,
          summary: summary,
          improvedPrompt: improvedPrompt,
        ),
      );
    } on DioException catch (error) {
      return FailureResult(
        NetworkFailure(_describeDioError(error), cause: error),
      );
    } on FormatException catch (error) {
      return FailureResult(
        ParsingFailure('Failed to parse OpenAI response.', cause: error),
      );
    } catch (error) {
      return FailureResult(
        UnknownFailure(
          'Unexpected error generating clarification.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required String summary,
    String? clarificationAnswers,
    String? userProfileContext,
  }) async {
    try {
      final userContext = StringBuffer()
        ..writeln('User request: $prompt')
        ..writeln('Intake summary: $summary');
      if (userProfileContext != null && userProfileContext.trim().isNotEmpty) {
        userContext
          ..writeln('Saved user profile:')
          ..writeln(userProfileContext.trim());
      }
      if (clarificationAnswers != null &&
          clarificationAnswers.trim().isNotEmpty) {
        userContext.writeln('Clarification answers: $clarificationAnswers');
      }

      final request = OpenAIChatRequest(
        model: _config.model,
        maxTokens: maxTokens,
        messages: [
          OpenAIChatMessage(
            role: 'system',
            content: '${tone.systemPrompt}\n\n$finalProposalPrompt',
          ),
          OpenAIChatMessage(role: 'user', content: userContext.toString()),
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
        NetworkFailure(_describeDioError(error), cause: error),
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

  String _stripJsonCodeFence(String content) {
    var trimmed = content.trim();
    if (trimmed.startsWith('```')) {
      trimmed = trimmed.replaceFirst(RegExp(r'^```(?:json)?'), '');
      if (trimmed.endsWith('```')) {
        trimmed = trimmed.substring(0, trimmed.length - 3);
      }
    }
    return trimmed.trim();
  }

  Map<String, dynamic>? _parseClarificationPayload(String content) {
    final trimmed = _stripJsonCodeFence(content);
    final directPayload = _decodeJsonObject(trimmed);
    if (directPayload != null) {
      return directPayload;
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      return null;
    }

    final candidate = trimmed.substring(start, end + 1);
    return _decodeJsonObject(candidate);
  }

  Map<String, dynamic>? _decodeJsonObject(String content) {
    try {
      final payload = jsonDecode(content);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  String _describeDioError(DioException error) {
    final response = error.response;
    if (response == null) {
      return 'Failed to reach the OpenAI API.';
    }

    final status = response.statusCode;
    final data = response.data;
    final body = data == null ? 'No response body.' : data.toString();
    final statusLabel = status == null ? '' : ' ($status)';
    return 'OpenAI API error$statusLabel: $body';
  }
}
