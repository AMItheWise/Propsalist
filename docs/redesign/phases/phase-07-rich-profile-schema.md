# Phase 07 - Rich Profile Schema and Prompt Context Upgrade

Source roadmap items:
- Richer profile schema.
- Split education, portfolio links, skills, experience, location, timezone,
  avatar, and success metrics into structured fields.
- Improve prompt context based on the richer profile data.

## Goal

Replace the current basic profile shape with structured professional context
that can improve proposal generation and support the redesigned profile UI
without stuffing unrelated data into free-text fields.

## Dependencies

- Phase 01 user-owned profile paths.
- Phase 02 proposal persistence, so generated proposals can store the profile
  context snapshot used at generation time.

## Scope

- Add versioned rich profile domain model.
- Add structured editing UI for profile sections.
- Add migration from existing basic profile fields.
- Update prompt context generation.
- Store a profile context snapshot on proposals.
- Keep backward compatibility with existing saved profiles during migration.

## Data Model

Add or evolve `UserProfile` with:

- `schemaVersion`
- `displayName`
- `headline`
- `bio`
- `location`
- `timezone`
- `avatarUrl`
- `skills`: structured list with name and category.
- `experience`: company, role, start/end dates, summary, highlights.
- `education`: institution, credential, field, year, notes.
- `portfolioLinks`: label, url, category, featured.
- `certifications`: name, issuer, year, url.
- `successMetrics`: label, value, context.
- `preferredIndustries`
- `defaultProposalTone`
- `updatedAt`

Add `ProfileContextSnapshot` on proposal records:

- `profileId`
- `profileSchemaVersion`
- `displayName`
- `headline`
- `skills`
- `experienceHighlights`
- `portfolioLinks`
- `successMetrics`
- `capturedAt`

## Migration Work

- Map existing basic fields into rich fields:
  - name/title into `displayName` and `headline`.
  - summary/about into `bio`.
  - skills text into a skills list when safely separable.
  - portfolio text into links only when valid URLs can be detected.
- Preserve original free-text values in a legacy notes field if parsing is not
  reliable.
- Set `schemaVersion` to the new version after migration.
- Run migration lazily when profile loads.

## Prompt Context Work

- Add `ProfilePromptContextBuilder`.
- Keep prompt context compact and deterministic.
- Include only user-approved or user-visible profile fields.
- Include proposal-specific `ProfileContextSnapshot` when regenerating an older
  proposal, unless the user chooses to refresh profile context.
- Add tests so prompt context changes are intentional and visible in snapshots.

## UI Work

- Profile Overview:
  - avatar, name, headline, location, timezone, and completion summary.
- Basic Info:
  - display name, headline, bio, preferred industries, default tone.
- Skills:
  - add/edit/remove skill chips and categories.
- Experience:
  - list entries with role, company, dates, summary, highlights.
- Education and Certifications:
  - structured repeated rows.
- Portfolio:
  - label, URL, category, featured flag, validation.
- Success Metrics:
  - repeated metric rows.
- Prompt Context Preview:
  - show generated context preview.
  - allow refresh after editing.

## Validation

- URLs must be valid before saving as portfolio links.
- Timezone should use known timezone identifiers where available.
- Avatar URL must be HTTPS or a Firebase Storage URL.
- Repeated sections should reject empty rows.
- Profile form should save partial valid sections without blocking unrelated
  valid edits.

## Tests

- Unit test basic-to-rich migration.
- Unit test prompt context builder output.
- Unit test profile serialization and validation.
- Widget test each profile section add/edit/remove flow.
- Widget test invalid portfolio URL error state.
- Widget test prompt context preview updates after edits.
- Golden test Profile Overview and key edit sections at mobile widths.

## Acceptance Criteria

- Profile data is structured and versioned.
- Existing basic profiles migrate without data loss.
- Proposal generation uses richer prompt context.
- Saved proposals retain the profile context snapshot used for generation.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Public profile pages.
- Avatar upload pipeline if Firebase Storage is not already configured.
- Importing profile data from LinkedIn or resumes.
- AI-assisted profile rewriting.

