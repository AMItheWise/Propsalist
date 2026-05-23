# Phase 03 - Dashboard Metrics, History Search, and Filters

Source roadmap items:
- Dashboard metrics.
- Proposal history search and filters.
- Search, status, tone, tag, sort, and pagination against stored proposals.

## Goal

Replace static dashboard stats and proposal history controls with real derived
data from persisted proposals and profiles. Users should be able to search and
filter their proposal history without changing the mobile visual design.

## Dependencies

- Phase 01 user-owned data paths.
- Phase 02 persisted proposal records.

## Scope

- Add dashboard metrics use case.
- Add query models for proposal history search and filters.
- Add repository methods for filtered proposal lists and pagination.
- Wire Dashboard and Proposals tabs to real data.
- Add Firestore indexes required by the chosen queries.

## Metrics

Add `DashboardMetrics`:

- `totalProposals`
- `generatedThisWeek`
- `draftCount`
- `needsClarificationCount`
- `archivedCount`
- `savedProfileCount`
- `clarificationCount`
- `weeklyTrendPercent`
- `latestProposalUpdatedAt`

Metric windows:

- week starts Monday in the user's local timezone.
- trend compares the current week to the previous complete week.
- when there is no previous week data, show neutral trend state instead of
  infinite growth.

## History Query Model

Add `ProposalHistoryQuery`:

- `searchText`
- `statuses`
- `tones`
- `tags`
- `sort`: `updatedDesc`, `updatedAsc`, `createdDesc`, `titleAsc`
- `pageSize`
- `cursor`

Add `ProposalHistoryPage`:

- `items`
- `nextCursor`
- `hasMore`

## Repository Work

Extend `ProposalStoreRepository` or add a focused read repository:

- `Stream<DashboardMetrics> watchDashboardMetrics()`
- `Future<Result<ProposalHistoryPage>> searchProposals(ProposalHistoryQuery query)`
- `Stream<List<String>> watchKnownTags()`

Firestore query notes:

- status and tone filters should use simple indexed fields.
- tags should use `array-contains` or `array-contains-any`.
- full text search should start with local filtering over the current page or a
  normalized `searchTokens` field. Do not pretend Firestore provides true full
  text search.
- add index documentation for compound sorts and filters.

## UI Work

- Dashboard:
  - replace static stat cards with `DashboardMetrics`.
  - show loading skeletons matching current card dimensions.
  - show neutral empty state when no proposals exist.
  - keep the visual companion and quick actions unchanged unless data requires
    minor copy updates.
- Proposals:
  - wire search input to debounced query state.
  - wire status, tone, tag, and sort controls.
  - add paginated loading at the bottom of the list.
  - keep mobile tap targets at least 44px.
  - preserve empty and error states for filtered results.

## Tests

- Unit test weekly metric calculations, including timezone boundary cases.
- Unit test query serialization and Firestore cursor behavior.
- Widget test Dashboard loading, empty, and populated metric states.
- Widget test Proposals search debounce and clear behavior.
- Widget test status, tone, tag, and sort filters.
- Widget test pagination appends results without duplicating cards.
- Golden test Dashboard and Proposals for 360, 390, and 430 width devices.

## Acceptance Criteria

- Dashboard no longer depends on static metric values.
- Proposal history search and filters operate on persisted proposal records.
- Filtering has explicit empty and error states.
- Required Firestore indexes are documented.
- `flutter analyze` and affected tests pass.

## Out of Scope

- External search services.
- Cross-user analytics.
- Proposal detail and version actions.

