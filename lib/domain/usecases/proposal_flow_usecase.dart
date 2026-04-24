import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';

class ProposalFlowUseCase {
  const ProposalFlowUseCase({required ProposalRepository repository})
    : _repository = repository;

  final ProposalRepository _repository;

  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) {
    return _repository.requestClarifications(
      prompt: prompt,
      userProfileContext: userProfileContext,
    );
  }

  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required String summary,
    String? clarificationAnswers,
    String? userProfileContext,
  }) {
    return _repository.generateProposal(
      prompt: prompt,
      tone: tone,
      maxTokens: maxTokens,
      summary: summary,
      clarificationAnswers: clarificationAnswers,
      userProfileContext: userProfileContext,
    );
  }
}
