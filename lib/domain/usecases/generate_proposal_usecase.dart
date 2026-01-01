import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';

class GenerateProposalUseCase {
  const GenerateProposalUseCase({required ProposalRepository repository})
    : _repository = repository;

  final ProposalRepository _repository;

  Future<Result<Proposal>> call({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) {
    return _repository.generateProposal(
      prompt: prompt,
      tone: tone,
      maxTokens: maxTokens,
    );
  }
}
