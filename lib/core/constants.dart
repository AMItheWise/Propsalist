const defaultMaxTokens = 256;
const minTokens = 64;
const maxTokensLimit = 512;
const defaultOpenAiModel = 'gpt-4o-mini';
const defaultOpenAiBaseUrl = 'https://api.openai.com';
const clarificationPrompt = '''
You are an intake assistant for proposal writing. Review the user request and
respond ONLY with valid JSON containing these keys:
- "needs_clarification" (boolean)
- "questions" (array of strings)
- "summary" (string)

If the request is clear, set "needs_clarification" to false, leave "questions"
empty, and provide a concise summary in "summary". Do not include any other
text or formatting.
''';

const finalProposalPrompt = '''
You are a proposal writer. Use the user's request and any clarifications to
write a concise, high-quality proposal. Return only the proposal text with no
extra commentary or formatting.
''';
