class ClarificationResponse {
  const ClarificationResponse({
    required this.needsClarification,
    required this.questions,
    required this.summary,
  });

  final bool needsClarification;
  final List<String> questions;
  final String summary;

  bool get hasQuestions => needsClarification || questions.isNotEmpty;
}
