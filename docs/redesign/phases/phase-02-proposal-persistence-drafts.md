# Phase 02 - Proposal Persistence and Draft Saving

Source roadmap items:
- Proposal persistence.
- Draft saving.
- Remove proposal history mock data where real data exists.

## Goal

Store generated proposals and drafts as first-class user-owned records. The New
Proposal screen should support saving a draft, generation should persist the
final output, and the Proposals tab should read real records instead of static
mock cards.

## Dependencies

- Phase 01 user-owned data paths and authenticated user id.

## Scope

- Add proposal persistence domain models.
- Add a proposal store repository separate from the OpenAI generation
  repository.
- Save drafts from the New Proposal form.
- Save generated proposal output after successful generation.
- Replace `mockProposalCardsProvider` with repository-backed providers.
- Keep the existing `ProposalRepository` OpenAI contract intact.

## Data Model

Add `ProposalRecord`:

- `id`
- `ownerId`
- `title`
- `clientName`
- `brief`
- `tone`
- `maxTokens`
- `status`: `draft`, `needsClarification`, `generated`, `archived`
- `tags`
- `promptSummary`
- `clarificationQuestions`
- `clarificationAnswers`
- `proposalContent`
- `createdAt`
- `updatedAt`
- `generatedAt`
- `lastOpenedAt`

Firestore path:

```text
users/{uid}/proposals/{proposalId}
```

Use server timestamps for persisted timestamp fields where possible.

## Repository Contract

Add `ProposalStoreRepository`:

- `Stream<List<ProposalRecord>> watchRecentProposals({int limit})`
- `Future<Result<ProposalRecord?>> getProposal(String id)`
- `Future<Result<String>> createDraft(ProposalDraftInput input)`
- `Future<Result<void>> updateDraft(String id, ProposalDraftInput input)`
- `Future<Result<void>> saveGeneratedProposal(GeneratedProposalInput input)`
- `Future<Result<void>> markNeedsClarification(ClarificationProposalInput input)`
- `Future<Result<void>> archiveProposal(String id)`

Do not merge this with the current OpenAI `ProposalRepository`; generation and
persistence have different failure modes and test doubles.

## UI Work

- New Proposal:
  - enable Save Draft when title, client, or brief has meaningful content.
  - show saving, saved, failed, and dirty states.
  - if the user generates from an unsaved form, save or update a draft first.
  - after generation succeeds, update the proposal status to `generated`.
- Clarifications:
  - persist clarification questions and user answers.
  - store `needsClarification` status if generation pauses for answers.
- Final Proposal:
  - show persisted proposal metadata.
  - expose a link back to the saved proposal detail placeholder until Phase 04.
- Proposals tab:
  - replace mock cards with `ProposalRecord` cards.
  - preserve empty, loading, and error surfaces.
  - keep static demonstration cards only in mock mode, clearly labeled in data
    providers rather than UI text.

## State Management

- Add Riverpod providers for recent proposals and active draft state.
- Extend proposal flow state to carry `activeProposalId`.
- Avoid storing form controller state inside repositories.
- Keep repository calls idempotent enough that retrying a failed save does not
  create duplicate generated proposals.

## Tests

- Unit test `ProposalStoreRepository` mapping and timestamp handling with fake
  Firestore.
- Unit test draft create/update behavior.
- Unit test generated proposal save behavior.
- Widget test:
  - Save Draft button disabled for empty form.
  - Save Draft creates a persisted draft.
  - generation persists a generated proposal.
  - Proposals tab shows repository data.
  - Proposals tab shows empty/loading/error states.
- Regression test that OpenAI generation still works with the existing
  `ProposalFlowUseCase`.

## Acceptance Criteria

- Drafts and generated proposals survive app restart when Firebase is
  configured.
- The Proposals tab can be driven entirely from stored proposal records.
- No placeholder proposal history data is shown outside mock mode.
- Failed persistence does not hide a successful OpenAI response; it shows a
  recoverable save error state.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Search and filtering beyond recent proposals.
- Version history.
- Export and sharing.
- Full proposal detail actions.

