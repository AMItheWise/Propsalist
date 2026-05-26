import 'package:proposal_writer/domain/entities/proposal_tone.dart';

enum ProposalStatus {
  draft('draft', 'Draft'),
  needsClarification('needsClarification', 'Needs Info'),
  generated('generated', 'Generated'),
  archived('archived', 'Archived');

  const ProposalStatus(this.value, this.label);

  final String value;
  final String label;

  static ProposalStatus fromValue(String? value) {
    return ProposalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProposalStatus.draft,
    );
  }
}

class ProposalRecord {
  const ProposalRecord({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.clientName,
    required this.brief,
    required this.tone,
    required this.maxTokens,
    required this.status,
    required this.tags,
    required this.promptSummary,
    required this.clarificationQuestions,
    required this.clarificationAnswers,
    required this.proposalContent,
    required this.createdAt,
    required this.updatedAt,
    required this.generatedAt,
    required this.lastOpenedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String clientName;
  final String brief;
  final ProposalTone tone;
  final int maxTokens;
  final ProposalStatus status;
  final List<String> tags;
  final String? promptSummary;
  final List<String> clarificationQuestions;
  final String? clarificationAnswers;
  final String? proposalContent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? generatedAt;
  final DateTime? lastOpenedAt;
}

class ProposalDraftInput {
  const ProposalDraftInput({
    required this.title,
    required this.clientName,
    required this.brief,
    required this.tone,
    required this.maxTokens,
    this.tags = const [],
  });

  final String title;
  final String clientName;
  final String brief;
  final ProposalTone tone;
  final int maxTokens;
  final List<String> tags;

  bool get hasMeaningfulContent {
    return title.trim().isNotEmpty ||
        clientName.trim().isNotEmpty ||
        brief.trim().isNotEmpty;
  }
}

class GeneratedProposalInput {
  const GeneratedProposalInput({
    required this.proposalId,
    required this.title,
    required this.clientName,
    required this.brief,
    required this.tone,
    required this.maxTokens,
    required this.promptSummary,
    required this.clarificationQuestions,
    required this.clarificationAnswers,
    required this.proposalContent,
    this.tags = const [],
  });

  final String? proposalId;
  final String title;
  final String clientName;
  final String brief;
  final ProposalTone tone;
  final int maxTokens;
  final String promptSummary;
  final List<String> clarificationQuestions;
  final String? clarificationAnswers;
  final String proposalContent;
  final List<String> tags;
}

class ClarificationProposalInput {
  const ClarificationProposalInput({
    required this.proposalId,
    required this.title,
    required this.clientName,
    required this.brief,
    required this.tone,
    required this.maxTokens,
    required this.promptSummary,
    required this.clarificationQuestions,
    required this.clarificationAnswers,
    this.tags = const [],
  });

  final String proposalId;
  final String title;
  final String clientName;
  final String brief;
  final ProposalTone tone;
  final int maxTokens;
  final String promptSummary;
  final List<String> clarificationQuestions;
  final String? clarificationAnswers;
  final List<String> tags;
}
