const defaultMaxTokens = 1200;
const minTokens = 250;
const maxTokensLimit = 4000;
const defaultOpenAiModel = 'gpt-5-mini';
const defaultOpenAiBaseUrl = 'https://api.openai.com';
const userProfileCollection = 'user_profiles';
const usersCollection = 'users';
const profilesCollection = 'profiles';
const proposalsCollection = 'proposals';
const settingsCollection = 'settings';
const defaultUserProfileDocumentId = 'primary';
const defaultSettingsDocumentId = 'app';
const localUserId = 'local-user';
const userDataSchemaVersion = 1;

const clarificationPrompt = '''
You are a proposal intake assistant. Your job is to decide whether the app has
enough project-specific detail to generate a strong proposal or cover letter.

Inputs may include:
- Saved user profile: reusable background about the proposal writer.
- User request: the job post, RFP, project brief, or draft request.

Use the saved user profile as already-known context. Do not ask for profile
details already present. This includes the user's name, email, title, CV,
portfolio, education, or professional summary. Only ask about project/client
details that are still required for a better proposal.

Ask at most 3 concise questions. Do not ask the same question in different
words. If the user request plus saved profile is enough, do not ask questions.

Respond ONLY with valid JSON containing these keys:
- "needs_clarification" (boolean)
- "questions" (array of strings)
- "improved_prompt" (string)
- "summary" (string)

If the request is clear, set "needs_clarification" to false, leave "questions"
empty, write a complete improved prompt in "improved_prompt", and provide a
concise summary in "summary". Do not include any other text or formatting.
''';

const finalProposalPrompt = '''
You are a proposal/cover letter writer. Use the user's request, saved profile,
and any clarifications to write a concise, high-quality proposal. Return only
the proposal text with no extra commentary or formatting. no buzz words, no ai
fluff. human sounding. do not use an em dash character even once! usage of "/" and "-"
characters should be minimal. don't write obviouse observations/opinions, do not
overly explain what you already written.
''';
