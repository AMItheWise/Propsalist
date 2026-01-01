import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/usecases/generate_proposal_usecase.dart';

class FakeProposalRepository implements ProposalRepository {
  FakeProposalRepository(this.result);

  final Result<Proposal> result;

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) async {
    return result;
  }
}

void main() {
  test('GenerateProposalUseCase returns repository result', () async {
    const expected = Success<Proposal>(Proposal(content: 'Hi'));
    final useCase = GenerateProposalUseCase(
      repository: FakeProposalRepository(expected),
    );

    final result = await useCase(
      prompt: 'Prompt',
      tone: ProposalTone.direct,
      maxTokens: 64,
    );

    expect(result, isA<Success<Proposal>>());
    result.when(
      success: (proposal) => expect(proposal.content, 'Hi'),
      failure: (_) => fail('Expected success'),
    );
  });
}
