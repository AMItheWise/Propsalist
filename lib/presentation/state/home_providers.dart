import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/presentation/models/mock_dashboard_data.dart';
import 'package:proposal_writer/presentation/state/proposal_flow_state.dart';

const _draftNotSet = Object();

final promptProvider = StateProvider<String>((ref) => '');
final toneProvider = StateProvider<ProposalTone>((ref) => ProposalTone.direct);
final maxTokensProvider = StateProvider<int>((ref) => defaultMaxTokens);
final mockProposalCardsProvider = Provider<List<MockProposalCard>>(
  (ref) => mockProposals,
);
final recentProposalsProvider =
    StreamProvider.autoDispose<List<ProposalRecord>>((ref) {
      return ref.watch(proposalStoreRepositoryProvider).watchRecentProposals();
    });
final dashboardRecentProposalsProvider =
    StreamProvider.autoDispose<List<ProposalRecord>>((ref) {
      return ref
          .watch(proposalStoreRepositoryProvider)
          .watchRecentProposals(limit: 5);
    });

enum DraftSaveStatus { idle, dirty, saving, saved, failed }

class ActiveDraftState {
  const ActiveDraftState({
    required this.status,
    required this.proposalId,
    required this.errorMessage,
  });

  factory ActiveDraftState.initial() => const ActiveDraftState(
    status: DraftSaveStatus.idle,
    proposalId: null,
    errorMessage: null,
  );

  final DraftSaveStatus status;
  final String? proposalId;
  final String? errorMessage;

  bool get isSaving => status == DraftSaveStatus.saving;

  ActiveDraftState copyWith({
    DraftSaveStatus? status,
    Object? proposalId = _draftNotSet,
    Object? errorMessage = _draftNotSet,
  }) {
    return ActiveDraftState(
      status: status ?? this.status,
      proposalId: proposalId == _draftNotSet
          ? this.proposalId
          : proposalId as String?,
      errorMessage: errorMessage == _draftNotSet
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class ActiveDraftNotifier extends StateNotifier<ActiveDraftState> {
  ActiveDraftNotifier(this._ref) : super(ActiveDraftState.initial());

  final Ref _ref;

  void markDirty() {
    if (state.status == DraftSaveStatus.saving) {
      return;
    }
    state = state.copyWith(status: DraftSaveStatus.dirty, errorMessage: null);
  }

  Future<Result<String>> save(ProposalDraftInput input) async {
    if (!input.hasMeaningfulContent) {
      const failure = ConfigurationFailure(
        'Add a title, client, or brief before saving a draft.',
      );
      state = state.copyWith(
        status: DraftSaveStatus.failed,
        errorMessage: failure.message,
      );
      return const FailureResult(failure);
    }

    state = state.copyWith(status: DraftSaveStatus.saving, errorMessage: null);

    final repository = _ref.read(proposalStoreRepositoryProvider);
    final existingId = state.proposalId;
    final result = existingId == null
        ? await repository.createDraft(input)
        : (await repository.updateDraft(existingId, input)).when(
            success: (_) => Success(existingId),
            failure: FailureResult<String>.new,
          );

    state = result.when(
      success: (proposalId) => state.copyWith(
        status: DraftSaveStatus.saved,
        proposalId: proposalId,
        errorMessage: null,
      ),
      failure: (failure) => state.copyWith(
        status: DraftSaveStatus.failed,
        errorMessage: failure.message,
      ),
    );
    return result;
  }
}

final activeDraftProvider =
    StateNotifierProvider<ActiveDraftNotifier, ActiveDraftState>(
      ActiveDraftNotifier.new,
    );

class ProposalFlowNotifier extends StateNotifier<ProposalFlowState> {
  ProposalFlowNotifier(this._ref) : super(ProposalFlowState.initial());

  final Ref _ref;

  Future<void> start({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required ProposalDraftInput draftInput,
    String? activeProposalId,
  }) async {
    String? userProfileContext;
    final profileResult = await _ref
        .read(userProfileUseCaseProvider)
        .loadProfile();
    profileResult.when(
      success: (profile) {
        final context = profile?.toPromptContext();
        if (context != null && context.isNotEmpty) {
          userProfileContext = context;
        }
      },
      failure: (_) {},
    );

    final request = ProposalRequest(
      prompt: prompt,
      tone: tone,
      maxTokens: maxTokens,
      userProfileContext: userProfileContext,
      draftInput: draftInput,
    );
    state = state.copyWith(
      stage: ProposalFlowStage.requestingClarifications,
      isLoading: true,
      awaitingClarifications: false,
      questions: [],
      summary: null,
      proposal: null,
      errorMessage: null,
      pendingRequest: request,
      generationPromptOverride: null,
      clarificationAnswers: null,
      activeProposalId: activeProposalId,
      saveErrorMessage: null,
    );
    final useCase = _ref.read(proposalFlowUseCaseProvider);
    final result = await useCase.requestClarifications(
      prompt: prompt,
      userProfileContext: request.userProfileContext,
    );
    await result.when(
      success: (clarification) async {
        if (clarification.hasQuestions) {
          state = state.copyWith(
            stage: ProposalFlowStage.awaitingClarifications,
            isLoading: false,
            awaitingClarifications: true,
            questions: clarification.questions,
            summary: clarification.summary,
            errorMessage: null,
          );
          await _markNeedsClarification(
            request: request,
            proposalId: activeProposalId,
            summary: clarification.summary,
            questions: clarification.questions,
            clarificationAnswers: null,
          );
          return;
        }
        await _generateProposal(
          request: request,
          proposalId: activeProposalId,
          summary: clarification.summary,
          promptOverride: clarification.improvedPrompt,
        );
      },
      failure: (failure) async {
        state = state.copyWith(
          stage: ProposalFlowStage.failure,
          isLoading: false,
          awaitingClarifications: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> submitClarifications(String answers) async {
    final request = state.pendingRequest;
    final summary = state.summary;
    if (request == null || summary == null) {
      return;
    }
    state = state.copyWith(
      stage: ProposalFlowStage.requestingClarifications,
      isLoading: true,
      errorMessage: null,
    );

    await _markNeedsClarification(
      request: request,
      proposalId: state.activeProposalId,
      summary: summary,
      questions: state.questions,
      clarificationAnswers: answers,
    );

    await _generateProposal(
      request: request,
      proposalId: state.activeProposalId,
      summary: summary,
      clarificationAnswers: answers,
    );
  }

  Future<void> _generateProposal({
    required ProposalRequest request,
    required String? proposalId,
    required String summary,
    String? clarificationAnswers,
    String? promptOverride,
  }) async {
    state = state.copyWith(
      stage: ProposalFlowStage.generating,
      isLoading: true,
      awaitingClarifications: false,
      errorMessage: null,
      summary: summary,
      generationPromptOverride: promptOverride,
      clarificationAnswers: clarificationAnswers,
    );
    final useCase = _ref.read(proposalFlowUseCaseProvider);
    final result = await useCase.generateProposal(
      prompt: promptOverride ?? request.prompt,
      tone: request.tone,
      maxTokens: request.maxTokens,
      summary: summary,
      clarificationAnswers: clarificationAnswers,
      userProfileContext: request.userProfileContext,
    );
    await result.when(
      success: (proposal) async {
        state = state.copyWith(
          stage: ProposalFlowStage.completed,
          isLoading: false,
          awaitingClarifications: false,
          proposal: proposal.content,
          errorMessage: null,
        );
        await _saveGeneratedProposal(
          request: request,
          proposalId: proposalId,
          summary: summary,
          clarificationAnswers: clarificationAnswers,
          proposalContent: proposal.content,
        );
      },
      failure: (failure) async {
        state = state.copyWith(
          stage: ProposalFlowStage.failure,
          isLoading: false,
          awaitingClarifications: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> retryGeneration() async {
    final request = state.pendingRequest;
    final summary = state.summary;
    if (request == null || summary == null) {
      return;
    }

    await _generateProposal(
      request: request,
      proposalId: state.activeProposalId,
      summary: summary,
      clarificationAnswers: state.clarificationAnswers,
      promptOverride: state.generationPromptOverride,
    );
  }

  Future<void> _markNeedsClarification({
    required ProposalRequest request,
    required String? proposalId,
    required String summary,
    required List<String> questions,
    required String? clarificationAnswers,
  }) async {
    if (proposalId == null) {
      return;
    }
    final result = await _ref
        .read(proposalStoreRepositoryProvider)
        .markNeedsClarification(
          ClarificationProposalInput(
            proposalId: proposalId,
            title: request.draftInput.title,
            clientName: request.draftInput.clientName,
            brief: request.draftInput.brief,
            tone: request.tone,
            maxTokens: request.maxTokens,
            promptSummary: summary,
            clarificationQuestions: questions,
            clarificationAnswers: clarificationAnswers,
            tags: request.draftInput.tags,
          ),
        );
    result.when(
      success: (_) {},
      failure: (failure) {
        state = state.copyWith(saveErrorMessage: failure.message);
      },
    );
  }

  Future<void> _saveGeneratedProposal({
    required ProposalRequest request,
    required String? proposalId,
    required String summary,
    required String? clarificationAnswers,
    required String proposalContent,
  }) async {
    final result = await _ref
        .read(proposalStoreRepositoryProvider)
        .saveGeneratedProposal(
          GeneratedProposalInput(
            proposalId: proposalId,
            title: request.draftInput.title,
            clientName: request.draftInput.clientName,
            brief: request.draftInput.brief,
            tone: request.tone,
            maxTokens: request.maxTokens,
            promptSummary: summary,
            clarificationQuestions: state.questions,
            clarificationAnswers: clarificationAnswers,
            proposalContent: proposalContent,
            tags: request.draftInput.tags,
          ),
        );
    result.when(
      success: (_) {},
      failure: (failure) {
        state = state.copyWith(saveErrorMessage: failure.message);
      },
    );
  }
}

final proposalFlowProvider =
    StateNotifierProvider<ProposalFlowNotifier, ProposalFlowState>(
      ProposalFlowNotifier.new,
    );
