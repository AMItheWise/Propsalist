import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/presentation/state/proposal_flow_state.dart';

final promptProvider = StateProvider<String>((ref) => '');
final toneProvider = StateProvider<ProposalTone>((ref) => ProposalTone.direct);
final maxTokensProvider = StateProvider<int>((ref) => defaultMaxTokens);

class ProposalFlowNotifier extends StateNotifier<ProposalFlowState> {
  ProposalFlowNotifier(this._ref) : super(ProposalFlowState.initial());

  final Ref _ref;

  Future<void> start({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) async {
    final request = ProposalRequest(
      prompt: prompt,
      tone: tone,
      maxTokens: maxTokens,
    );
    state = state.copyWith(
      isLoading: true,
      awaitingClarifications: false,
      questions: [],
      summary: null,
      proposal: null,
      errorMessage: null,
      pendingRequest: request,
    );
    final useCase = _ref.read(proposalFlowUseCaseProvider);
    final result = await useCase.requestClarifications(prompt: prompt);
    await result.when(
      success: (clarification) async {
        if (clarification.hasQuestions) {
          state = state.copyWith(
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
        );
      },
      failure: (failure) async {
        state = state.copyWith(
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _generateProposal(
      request: request,
      summary: summary,
      clarificationAnswers: answers,
    );
  }

  Future<void> _generateProposal({
    required ProposalRequest request,
    required String summary,
    String? clarificationAnswers,
  }) async {
    final useCase = _ref.read(proposalFlowUseCaseProvider);
    final result = await useCase.generateProposal(
      prompt: request.prompt,
      tone: request.tone,
      maxTokens: request.maxTokens,
      summary: summary,
      clarificationAnswers: clarificationAnswers,
    );
    state = result.when(
      success: (proposal) => state.copyWith(
        isLoading: false,
        awaitingClarifications: false,
        proposal: proposal.content,
        errorMessage: null,
      ),
      failure: (failure) => state.copyWith(
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
