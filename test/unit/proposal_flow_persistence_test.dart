import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/repositories/proposal_store_repository.dart';
import 'package:proposal_writer/presentation/state/home_providers.dart';
import 'package:proposal_writer/presentation/state/proposal_flow_state.dart';

class FakeProposalRepository implements ProposalRepository {
  const FakeProposalRepository({
    required this.clarificationResult,
    required this.proposalResult,
  });

  final Result<ClarificationResponse> clarificationResult;
  final Result<Proposal> proposalResult;

  @override
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
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
    return proposalResult;
  }
}

class RecordingProposalStoreRepository implements ProposalStoreRepository {
  final generatedInputs = <GeneratedProposalInput>[];
  final clarificationInputs = <ClarificationProposalInput>[];

  @override
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20}) {
    return Stream<List<ProposalRecord>>.value(const []);
  }

  @override
  Future<Result<ProposalRecord?>> getProposal(String id) async {
    return const Success(null);
  }

  @override
  Future<Result<String>> createDraft(ProposalDraftInput input) async {
    return const Success('created-draft');
  }

  @override
  Future<Result<void>> updateDraft(String id, ProposalDraftInput input) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> saveGeneratedProposal(
    GeneratedProposalInput input,
  ) async {
    generatedInputs.add(input);
    return const Success(null);
  }

  @override
  Future<Result<void>> markNeedsClarification(
    ClarificationProposalInput input,
  ) async {
    clarificationInputs.add(input);
    return const Success(null);
  }

  @override
  Future<Result<void>> archiveProposal(String id) async {
    return const Success(null);
  }
}

void main() {
  const draftInput = ProposalDraftInput(
    title: 'Website Redesign',
    clientName: 'Acme Inc.',
    brief: 'Write a website redesign proposal.',
    tone: ProposalTone.direct,
    maxTokens: 1200,
  );

  ProviderContainer buildContainer({
    required Result<ClarificationResponse> clarificationResult,
    required RecordingProposalStoreRepository proposalStoreRepository,
  }) {
    return ProviderContainer(
      overrides: [
        proposalRepositoryProvider.overrideWithValue(
          FakeProposalRepository(
            clarificationResult: clarificationResult,
            proposalResult: const Success(
              Proposal(content: 'Generated proposal content'),
            ),
          ),
        ),
        userProfileRepositoryProvider.overrideWithValue(
          const DisabledUserProfileRepository(),
        ),
        proposalStoreRepositoryProvider.overrideWithValue(
          proposalStoreRepository,
        ),
      ],
    );
  }

  test('proposal flow saves generated output on the active draft', () async {
    final proposalStoreRepository = RecordingProposalStoreRepository();
    final container = buildContainer(
      proposalStoreRepository: proposalStoreRepository,
      clarificationResult: const Success(
        ClarificationResponse(
          needsClarification: false,
          questions: [],
          summary: 'A website redesign proposal.',
          improvedPrompt: 'Improved prompt',
        ),
      ),
    );
    addTearDown(container.dispose);

    await container
        .read(proposalFlowProvider.notifier)
        .start(
          prompt: draftInput.brief,
          tone: draftInput.tone,
          maxTokens: draftInput.maxTokens,
          draftInput: draftInput,
          activeProposalId: 'draft-123',
        );

    expect(proposalStoreRepository.generatedInputs, hasLength(1));
    expect(
      proposalStoreRepository.generatedInputs.single.proposalId,
      'draft-123',
    );
    expect(
      proposalStoreRepository.generatedInputs.single.proposalContent,
      'Generated proposal content',
    );
    expect(
      container.read(proposalFlowProvider).stage,
      ProposalFlowStage.completed,
    );
    expect(container.read(proposalFlowProvider).activeProposalId, 'draft-123');
  });

  test(
    'proposal flow saves clarification questions on the active draft',
    () async {
      final proposalStoreRepository = RecordingProposalStoreRepository();
      final container = buildContainer(
        proposalStoreRepository: proposalStoreRepository,
        clarificationResult: const Success(
          ClarificationResponse(
            needsClarification: true,
            questions: ['What is the deadline?'],
            summary: 'The proposal needs timeline detail.',
            improvedPrompt: '',
          ),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(proposalFlowProvider.notifier)
          .start(
            prompt: draftInput.brief,
            tone: draftInput.tone,
            maxTokens: draftInput.maxTokens,
            draftInput: draftInput,
            activeProposalId: 'draft-123',
          );

      expect(proposalStoreRepository.clarificationInputs, hasLength(1));
      expect(
        proposalStoreRepository.clarificationInputs.single.proposalId,
        'draft-123',
      );
      expect(
        proposalStoreRepository
            .clarificationInputs
            .single
            .clarificationQuestions,
        ['What is the deadline?'],
      );
      expect(
        container.read(proposalFlowProvider).awaitingClarifications,
        isTrue,
      );
      expect(
        container.read(proposalFlowProvider).activeProposalId,
        'draft-123',
      );
    },
  );
}
