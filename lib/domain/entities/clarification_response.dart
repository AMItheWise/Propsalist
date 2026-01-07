class ClarificationResponse {
  const ClarificationResponse({
    required this.needsClarification,
    required this.questions,
    required this.summary,
    required this.improvedPrompt,
  });

  final bool needsClarification;
  final List<String> questions;
  final String summary;
  final String improvedPrompt;

  bool get hasQuestions => needsClarification || questions.isNotEmpty;
}
