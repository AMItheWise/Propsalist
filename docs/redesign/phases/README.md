# Proposalist Redesign Implementation Phases

Source roadmap: [../mobile-mockup-gap-roadmap.md](../mobile-mockup-gap-roadmap.md)

These plans turn the mobile mockup gap roadmap into implementation phases. The
order is intentional: first create user-owned data boundaries, then replace
static UI data with persisted behavior, then layer detail actions, exports,
settings, theme work, and richer profile context.

## Phase Order

1. [Auth, Data Ownership, and Firestore Foundations](phase-01-auth-data-ownership.md)
2. [Proposal Persistence and Draft Saving](phase-02-proposal-persistence-drafts.md)
3. [Dashboard Metrics, History Search, and Filters](phase-03-dashboard-history-search.md)
4. [Proposal Detail, Versioning, and Editing Actions](phase-04-proposal-detail-versioning.md)
5. [Export, Download, Copy, and Share](phase-05-export-share.md)
6. [Settings Persistence, Appearance, and Dark Mode](phase-06-settings-theme-dark-mode.md)
7. [Rich Profile Schema and Prompt Context Upgrade](phase-07-rich-profile-schema.md)

## Global Completion Rule

Before removing a placeholder label or mock data source, the implementing phase
must add the domain model, repository contract, persistence behavior, tests, and
security rules. If a feature remains local-only, the phase must document that
decision in code comments or product docs before the placeholder is removed.

