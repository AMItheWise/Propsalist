enum ProposalTone {
  direct('Direct', 'Be direct and concise.'),
  friendly('Friendly', 'Use a warm and approachable tone.'),
  formal('Formal', 'Use a professional and formal tone.');

  const ProposalTone(this.label, this.systemPrompt);

  final String label;
  final String systemPrompt;
}
