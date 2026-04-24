import 'package:proposal_writer/domain/entities/proposal_tone.dart';

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
    required this.isLoading,
    required this.awaitingClarifications,
    required this.questions,
    required this.summary,
    required this.proposal,
    required this.errorMessage,
    required this.pendingRequest,
  });

  final bool isLoading;
  final bool awaitingClarifications;
  final List<String> questions;
  final String? summary;
  final String? proposal;
  final String? errorMessage;
  final ProposalRequest? pendingRequest;

  factory ProposalFlowState.initial() => const ProposalFlowState(
    isLoading: false,
    awaitingClarifications: false,
    questions: [],
    summary: null,
    proposal: null,
    errorMessage: null,
    pendingRequest: null,
  );

  ProposalFlowState copyWith({
    bool? isLoading,
    bool? awaitingClarifications,
    List<String>? questions,
    String? summary,
    String? proposal,
    String? errorMessage,
    ProposalRequest? pendingRequest,
  }) {
    return ProposalFlowState(
      isLoading: isLoading ?? this.isLoading,
      awaitingClarifications:
          awaitingClarifications ?? this.awaitingClarifications,
      questions: questions ?? this.questions,
      summary: summary ?? this.summary,
      proposal: proposal ?? this.proposal,
      errorMessage: errorMessage,
      pendingRequest: pendingRequest ?? this.pendingRequest,
    );
  }
}
