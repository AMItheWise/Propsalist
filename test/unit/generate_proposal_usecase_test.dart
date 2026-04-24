import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/usecases/proposal_flow_usecase.dart';

class FakeProposalRepository implements ProposalRepository {
  FakeProposalRepository({
    required this.clarificationResult,
    required this.proposalResult,
  });

  final Result<ClarificationResponse> clarificationResult;
  final Result<Proposal> proposalResult;
  String? lastClarificationProfileContext;
  String? lastProposalProfileContext;

  @override
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
    lastClarificationProfileContext = userProfileContext;
    return clarificationResult;
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
    lastProposalProfileContext = userProfileContext;
    return proposalResult;
  }
}

void main() {
  test('ProposalFlowUseCase forwards clarification profile context', () async {
    final repository = FakeProposalRepository(
      clarificationResult: const Success(
        ClarificationResponse(
          needsClarification: false,
          questions: [],
          summary: 'summary',
          improvedPrompt: 'prompt',
        ),
      ),
      proposalResult: const Success(Proposal(content: 'Hi')),
    );
    final useCase = ProposalFlowUseCase(repository: repository);

    final result = await useCase.requestClarifications(
      prompt: 'Prompt',
      userProfileContext: 'Saved profile',
    );

    expect(result, isA<Success<ClarificationResponse>>());
    expect(repository.lastClarificationProfileContext, 'Saved profile');
  });

  test('ProposalFlowUseCase returns repository proposal result', () async {
    const expected = Success<Proposal>(Proposal(content: 'Hi'));
    final repository = FakeProposalRepository(
      clarificationResult: const Success(
        ClarificationResponse(
          needsClarification: false,
          questions: [],
          summary: 'summary',
          improvedPrompt: 'prompt',
        ),
      ),
      proposalResult: expected,
    );
    final useCase = ProposalFlowUseCase(repository: repository);

    final result = await useCase.generateProposal(
      prompt: 'Prompt',
      tone: ProposalTone.direct,
      maxTokens: 64,
      summary: 'summary',
      userProfileContext: 'Saved profile',
    );

    expect(result, isA<Success<Proposal>>());
    expect(repository.lastProposalProfileContext, 'Saved profile');
    result.when(
      success: (proposal) => expect(proposal.content, 'Hi'),
      failure: (_) => fail('Expected success'),
    );
  });
}
