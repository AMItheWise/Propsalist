# Phase 06 - Settings Persistence, Appearance, and Dark Mode

Source roadmap items:
- Settings persistence.
- Save OpenAI, Firebase, mock mode, appearance, analytics, crash report,
  retention, currency, and shortcut preferences.
- Dark mode.

## Goal

Turn the Settings placeholder into persisted preferences and connect appearance
settings to the app theme. Keep secret handling explicit: client-side settings
must not store production API keys in Firestore.

## Dependencies

- Phase 01 user-owned data paths.

## Scope

- Add settings entity and repository.
- Persist non-secret user preferences.
- Add mock mode and integration status controls.
- Add theme mode and dark palette support.
- Add analytics, crash reporting, retention, currency, and shortcut preference
  rows.
- Document secret configuration boundaries.

## Security Decision

Do not persist raw OpenAI API keys or Firebase secrets in Firestore from the
mobile client. Production OpenAI credentials should come from environment
configuration or a secure backend proxy. Settings may persist:

- selected model name if it is not secret.
- mock mode preference for development builds.
- integration status and diagnostics.
- non-secret Firebase project display metadata if needed.

If the product later requires user-supplied keys, store them only in platform
secure storage and document the risk clearly in the settings UI.

## Settings Model

Add `AppSettings`:

- `themeMode`: `system`, `light`, `dark`
- `useDynamicColor`
- `mockModeEnabled`
- `preferredModel`
- `analyticsEnabled`
- `crashReportingEnabled`
- `retentionDays`
- `defaultCurrency`
- `showKeyboardShortcuts`
- `exportIncludesMetadataByDefault`
- `updatedAt`

Firestore path:

```text
users/{uid}/settings/app
```

Local-only fields, if required:

- secure API key presence flag.
- local development override flags.

## Repository Work

Add `SettingsRepository`:

- `Stream<AppSettings> watchSettings()`
- `Future<Result<void>> saveSettings(AppSettings settings)`
- `Future<Result<void>> resetSettings()`

Add defaults provider:

- system theme.
- mock mode follows existing environment configuration by default.
- analytics and crash reporting default off until product policy is defined.
- retention defaults to no automatic deletion until retention behavior exists.

## Theme Work

- Extend `ProposalistTheme` with a dark theme.
- Keep color tokens paired by semantic role rather than ad hoc colors.
- Update `MaterialApp` to watch `themeMode`.
- Audit all custom components for hard-coded light colors.
- Keep mobile goldens for light mode; add focused dark-mode goldens for primary
  screens and settings.

## UI Work

- Settings:
  - real persisted rows for appearance, model, mock mode, analytics, crash
    reporting, retention, currency, shortcuts, and export defaults.
  - integration status cards for OpenAI and Firebase.
  - reset settings action with confirmation.
  - inline warnings for settings that require app restart or secure backend work.
- Profile:
  - link to Settings remains available from Profile.

## Tests

- Unit test settings defaults and serialization.
- Unit test save/reset repository behavior with fake Firestore.
- Widget test changing theme mode updates app theme.
- Widget test mock mode setting is disabled or clearly marked when runtime config
  does not allow switching.
- Widget test settings reset confirmation.
- Golden test Dashboard, New Proposal, Profile, and Settings in dark mode.

## Acceptance Criteria

- Settings changes persist per user.
- Theme mode changes take effect without restarting the app.
- Dark mode matches the design-system mockup palette closely.
- No raw production API key is written to Firestore.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Backend proxy for OpenAI.
- Analytics provider integration.
- Crash reporting provider integration.
- Automatic data deletion by retention policy.

