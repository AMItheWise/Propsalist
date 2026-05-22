# Proposalist Mobile Mockup Gap Roadmap

This document tracks mockup features that are intentionally represented as
placeholders in the first mobile UI redesign pass.

## Implemented In This Pass

- Mobile app shell with bottom navigation.
- Dashboard, new proposal, clarifications, final proposal, proposals, profile,
  settings, loading, empty, and error surfaces.
- Existing proposal generation and clarification flow.
- Existing Firestore-backed single user profile fields.
- Proposalist visual system: colors, spacing, cards, chips, badges, buttons,
  inputs, progress steps, and mobile layout constraints.

## Placeholder Features To Integrate Later

- Proposal persistence: store generated proposals, drafts, statuses, tags,
  client names, timestamps, and prompt summaries.
- Dashboard metrics: replace static stats with real weekly counts, trends,
  saved profile counts, and clarification counts.
- Proposal history search and filters: wire search, status, tone, tag, sort,
  and pagination to stored proposals.
- Draft saving: implement save draft from the New Proposal screen.
- Proposal detail and versions: add version history, comparison, notes, archive,
  duplicate, edit, and regenerate flows.
- Export and download: add PDF/doc export, plain-text copy options, and share
  targets.
- Settings persistence: save OpenAI, Firebase, mock mode, appearance, analytics,
  crash report, retention, currency, and shortcut preferences.
- Authentication and multi-user profiles: replace the single
  `user_profiles/primary` document with per-user ownership and security rules.
- Richer profile schema: split education, portfolio links, skills, experience,
  location, timezone, avatar, and success metrics into structured fields.
- Dark mode: implement the dark palette shown in the design-system mockup.

## Completion Rule

Before removing any placeholder label or static data set, add the missing domain
model, repository contract, persistence behavior, tests, and security rules or
document why the feature remains local-only.
