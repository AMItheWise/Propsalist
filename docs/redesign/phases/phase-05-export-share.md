# Phase 05 - Export, Download, Copy, and Share

Source roadmap items:
- Export and download.
- PDF/doc export.
- Plain-text copy options.
- Share targets.

## Goal

Allow users to move finalized proposal content out of Proposalist in common
mobile-friendly formats while keeping export generation testable and separated
from proposal storage.

## Dependencies

- Phase 02 persisted proposal records.
- Phase 04 proposal detail and versions.

## Scope

- Add export domain models and service contracts.
- Add plain-text copy behavior.
- Add PDF export.
- Add DOCX export.
- Add native share sheet integration.
- Add export UI from Final Proposal and Proposal Detail.

## Export Model

Add `ProposalExportRequest`:

- `proposalId`
- `versionId`
- `format`: `plainText`, `pdf`, `docx`
- `includeClientName`
- `includeProfileSummary`
- `includePromptSummary`
- `includeGeneratedDate`

Add `ProposalExportResult`:

- `fileName`
- `mimeType`
- `bytes`
- `plainText`
- `createdAt`

## Service Contracts

Add `ProposalExportService`:

- `Future<Result<ProposalExportResult>> buildExport(ProposalExportRequest request)`
- `Future<Result<void>> copyPlainText(ProposalExportRequest request)`
- `Future<Result<void>> shareExport(ProposalExportRequest request)`

Implementation guidance:

- Keep format builders pure where possible so unit tests can assert bytes and
  text without invoking platform channels.
- Use a platform adapter for clipboard and share sheet behavior.
- Store temporary files in the platform cache directory and delete stale files
  opportunistically.

## Format Decisions

- Plain text: deterministic first implementation and baseline for copy/share.
- PDF: use a Dart PDF builder with Proposalist typography, margins, headings,
  metadata, and page breaks.
- DOCX: generate a simple Office Open XML document with proposal title, client,
  body paragraphs, and metadata. Avoid advanced formatting until export fidelity
  is validated on mobile.

## UI Work

- Final Proposal:
  - add copy, export, and share actions.
  - show disabled states when there is no generated content.
- Proposal Detail:
  - export current version by default.
  - allow selecting a version from the version menu before export.
- Export Sheet:
  - format picker: text, PDF, DOCX.
  - toggles for included metadata.
  - actions: Copy, Share, Save/Download where supported.
  - loading, success, and error states.

## File Naming

Use deterministic sanitized filenames:

```text
proposalist-{client-or-project}-{yyyyMMdd}-{version}.pdf
proposalist-{client-or-project}-{yyyyMMdd}-{version}.docx
proposalist-{client-or-project}-{yyyyMMdd}-{version}.txt
```

## Tests

- Unit test plain text output formatting.
- Unit test PDF and DOCX builders produce non-empty bytes and expected metadata.
- Unit test filename sanitizer.
- Widget test export sheet state transitions.
- Widget test disabled export actions for missing content.
- Widget test export errors surface clearly without losing proposal content.
- Platform adapter tests should use fakes for clipboard, file, and share calls.

## Acceptance Criteria

- Users can copy proposal text from the final proposal and detail screens.
- Users can generate PDF and DOCX export files for a saved proposal version.
- Users can open the platform share sheet with an exported file.
- Export failures are non-destructive and retryable.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Custom branded export templates.
- Server-side document generation.
- Cloud storage sync.
- E-signature workflows.

