import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';

abstract class ProposalRepository {
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
  });

  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required String summary,
    String? clarificationAnswers,
  });
}
