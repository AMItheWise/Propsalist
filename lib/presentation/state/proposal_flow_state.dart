import 'package:proposal_writer/domain/entities/proposal_tone.dart';

const _notSet = Object();

enum ProposalFlowStage {
  idle,
  requestingClarifications,
  awaitingClarifications,
  generating,
  completed,
  failure,
}

class ProposalRequest {
  const ProposalRequest({
    required this.prompt,
    required this.tone,
    required this.maxTokens,
    required this.userProfileContext,
  });

  final String prompt;
  final ProposalTone tone;
  final int maxTokens;
  final String? userProfileContext;
}

class ProposalFlowState {
  const ProposalFlowState({
    required this.stage,
    required this.isLoading,
    required this.awaitingClarifications,
    required this.questions,
    required this.summary,
    required this.proposal,
    required this.errorMessage,
    required this.pendingRequest,
  });

  factory ProposalFlowState.initial() => const ProposalFlowState(
    stage: ProposalFlowStage.idle,
    isLoading: false,
    awaitingClarifications: false,
    questions: [],
    summary: null,
    proposal: null,
    errorMessage: null,
    pendingRequest: null,
  );

  final ProposalFlowStage stage;
  final bool isLoading;
  final bool awaitingClarifications;
  final List<String> questions;
  final String? summary;
  final String? proposal;
  final String? errorMessage;
  final ProposalRequest? pendingRequest;

  ProposalFlowState copyWith({
    ProposalFlowStage? stage,
    bool? isLoading,
    bool? awaitingClarifications,
    List<String>? questions,
    Object? summary = _notSet,
    Object? proposal = _notSet,
    Object? errorMessage = _notSet,
    Object? pendingRequest = _notSet,
  }) {
    return ProposalFlowState(
      stage: stage ?? this.stage,
      isLoading: isLoading ?? this.isLoading,
      awaitingClarifications:
          awaitingClarifications ?? this.awaitingClarifications,
      questions: questions ?? this.questions,
      summary: summary == _notSet ? this.summary : summary as String?,
      proposal: proposal == _notSet ? this.proposal : proposal as String?,
      errorMessage: errorMessage == _notSet
          ? this.errorMessage
          : errorMessage as String?,
      pendingRequest: pendingRequest == _notSet
          ? this.pendingRequest
          : pendingRequest as ProposalRequest?,
    );
  }
}
