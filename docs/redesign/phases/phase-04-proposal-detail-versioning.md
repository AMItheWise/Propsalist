# Phase 04 - Proposal Detail, Versioning, and Editing Actions

Source roadmap items:
- Proposal detail and versions.
- Version history, comparison, notes, archive, duplicate, edit, and regenerate
  flows.

## Goal

Turn saved proposal cards into useful proposal records. Users should be able to
open a proposal, inspect its metadata and content, create edited or regenerated
versions, compare versions, add notes, duplicate records, and archive proposals.

## Dependencies

- Phase 01 user-owned data paths.
- Phase 02 persisted proposal records.
- Phase 03 proposal history list wiring.

## Scope

- Add proposal detail route or shell state.
- Add version models and persistence.
- Add edit, regenerate, duplicate, archive, and notes actions.
- Add comparison UI for two proposal versions.
- Keep OpenAI generation through the existing `ProposalFlowUseCase`.

## Data Model

Add `ProposalVersion`:

- `id`
- `proposalId`
- `versionNumber`
- `source`: `initial`, `manualEdit`, `regenerated`, `duplicated`
- `title`
- `content`
- `promptSummary`
- `tone`
- `maxTokens`
- `createdAt`
- `createdBy`
- `notes`

Store versions at:

```text
users/{uid}/proposals/{proposalId}/versions/{versionId}
```

Update `ProposalRecord` with:

- `currentVersionId`
- `versionCount`
- `archivedAt`
- `duplicatedFromProposalId`
- `noteCount`

## Repository Work

Add or extend repository methods:

- `Stream<ProposalRecord?> watchProposal(String proposalId)`
- `Stream<List<ProposalVersion>> watchVersions(String proposalId)`
- `Future<Result<String>> createVersion(CreateProposalVersionInput input)`
- `Future<Result<void>> setCurrentVersion(String proposalId, String versionId)`
- `Future<Result<String>> duplicateProposal(String proposalId)`
- `Future<Result<void>> archiveProposal(String proposalId)`
- `Future<Result<void>> updateProposalNotes(String proposalId, String notes)`

Use a Firestore transaction or batched write when creating a version and
updating `currentVersionId`.

## UI Work

- Proposal Detail:
  - header with title, client, status badge, updated date, and overflow actions.
  - content preview with selectable/copyable text.
  - metadata section for tone, tokens, tags, prompt summary, and profile context.
  - notes section with saved/dirty/error states.
  - version timeline section.
- Edit:
  - local editable content view.
  - saving creates a new `manualEdit` version.
  - original generated version remains available.
- Regenerate:
  - prefill request from stored proposal metadata.
  - call existing proposal flow.
  - save response as a new `regenerated` version.
  - keep failed regeneration recoverable.
- Compare:
  - allow selecting any two versions.
  - show mobile-friendly stacked comparison first.
  - highlight changed paragraphs or sections if feasible without a heavy diff
    package.
- Archive:
  - confirm before archiving.
  - remove archived items from default history filters.
  - keep archived status filter available.
- Duplicate:
  - copy proposal metadata and current content into a new proposal record.
  - first version source should be `duplicated`.

## Tests

- Unit test version transaction behavior.
- Unit test duplicate preserves metadata and creates a new id.
- Unit test archive updates status and archived timestamp.
- Widget test detail loading, populated, empty, and error states.
- Widget test edit creates a new version.
- Widget test regenerate calls proposal flow and saves a new version.
- Widget test compare selector and output.
- Widget test archive confirmation.
- Golden test proposal detail and compare screens at mobile widths.

## Acceptance Criteria

- Tapping a proposal card opens a real detail surface.
- Edits and regenerations never overwrite previous versions.
- Users can recover from failed edit/regenerate/save actions.
- Archived proposals are hidden by default but not deleted.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Collaborative editing.
- Rich text editor formatting.
- Server-side diff generation.
- Permanent delete.

