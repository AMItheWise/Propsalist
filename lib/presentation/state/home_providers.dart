import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/presentation/models/mock_dashboard_data.dart';
import 'package:proposal_writer/presentation/state/proposal_flow_state.dart';

final promptProvider = StateProvider<String>((ref) => '');
final toneProvider = StateProvider<ProposalTone>((ref) => ProposalTone.direct);
final maxTokensProvider = StateProvider<int>((ref) => defaultMaxTokens);
final mockProposalCardsProvider = Provider<List<MockProposalCard>>(
  (ref) => mockProposals,
);

class ProposalFlowNotifier extends StateNotifier<ProposalFlowState> {
  ProposalFlowNotifier(this._ref) : super(ProposalFlowState.initial());

  final Ref _ref;

  Future<void> start({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
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
          return;
        }
        await _generateProposal(
          request: request,
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
    final clarifiedPrompt = StringBuffer()
      ..writeln('User request: ${request.prompt}')
      ..writeln('Clarification answers: $answers');
    final useCase = _ref.read(proposalFlowUseCaseProvider);
    final result = await useCase.requestClarifications(
      prompt: clarifiedPrompt.toString(),
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
          return;
        }
        await _generateProposal(
          request: request,
          summary: clarification.summary,
          clarificationAnswers: answers,
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

  Future<void> _generateProposal({
    required ProposalRequest request,
    required String summary,
    String? clarificationAnswers,
    String? promptOverride,
  }) async {
    state = state.copyWith(
      stage: ProposalFlowStage.generating,
      isLoading: true,
      awaitingClarifications: false,
      errorMessage: null,
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
    state = result.when(
      success: (proposal) => state.copyWith(
        stage: ProposalFlowStage.completed,
        isLoading: false,
        awaitingClarifications: false,
        proposal: proposal.content,
        errorMessage: null,
      ),
      failure: (failure) => state.copyWith(
        stage: ProposalFlowStage.failure,
        isLoading: false,
        awaitingClarifications: false,
        errorMessage: failure.message,
      ),
    );
  }
}

final proposalFlowProvider =
    StateNotifierProvider<ProposalFlowNotifier, ProposalFlowState>(
      ProposalFlowNotifier.new,
    );
