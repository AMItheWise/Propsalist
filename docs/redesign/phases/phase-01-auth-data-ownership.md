# Phase 01 - Auth, Data Ownership, and Firestore Foundations

Source roadmap items:
- Authentication and multi-user profiles.
- Replace `user_profiles/primary` with per-user ownership and security rules.
- Prepare persisted proposals, drafts, settings, and richer profiles for later
  phases.

## Goal

Introduce a user-owned data boundary before adding proposal persistence. This
avoids building new features on top of the current global `user_profiles/primary`
document and keeps future proposal, settings, profile, and export data tied to a
single authenticated user.

## Scope

- Add an auth abstraction in the domain layer.
- Add Firebase Auth support in the data layer.
- Create user-scoped Firestore path helpers.
- Move profile reads and writes behind user-owned paths.
- Add security rules and tests for the new ownership model.
- Preserve mock/local development behavior when Firebase is not configured.

## Product Decisions

- Default sign-in behavior: Firebase anonymous authentication, so the mobile app
  keeps the current no-login flow while still receiving a stable `uid`.
- Future account upgrade: email, Google, Apple, and account linking are outside
  this phase but should fit the auth abstraction.
- Local/mock mode: when Firebase is disabled, expose a deterministic local user
  id such as `local-user` and keep persistence disabled or in-memory.

## Data Model

User-owned Firestore root:

```text
users/{uid}
users/{uid}/profiles/{profileId}
users/{uid}/proposals/{proposalId}
users/{uid}/settings/app
```

Initial profile id:

```text
primary
```

`users/{uid}` should contain lightweight account metadata:

- `createdAt`
- `updatedAt`
- `authProvider`
- `schemaVersion`
- `legacyProfileMigratedAt`

## Domain and Repository Work

- Add `AppUser` entity with `id`, `isAnonymous`, and optional display fields.
- Add `AuthRepository` contract:
  - `Stream<AppUser?> watchCurrentUser()`
  - `Future<Result<AppUser>> signInAnonymously()`
  - `Future<Result<void>> signOut()`
  - `Future<Result<void>> ensureSignedIn()`
- Add `UserDataPathResolver` or equivalent helper that derives Firestore paths
  from the current user id.
- Update `UserProfileRepository` implementation to read and write:
  - from `users/{uid}/profiles/primary`
  - not from `user_profiles/primary`
- Keep existing `UserProfileUseCase` public behavior stable for the UI.

## Migration Work

- On first authenticated launch, check legacy `user_profiles/primary`.
- If the new `users/{uid}/profiles/primary` document does not exist, copy the
  legacy profile into the new path.
- Write `legacyProfileMigratedAt` on `users/{uid}`.
- Do not delete the legacy document in this phase.
- Add a small migration helper that can be removed after production data is
  confirmed migrated.

## UI Work

- Add an auth bootstrapping state before the mobile shell renders.
- Show the existing loading surface while anonymous sign-in is pending.
- Show the existing error surface if Firebase auth is configured but sign-in
  fails.
- In mock mode, render normally with the local user id.
- Update profile messaging so it refers to user-owned Firestore data instead of
  a global profile document.

## Security Rules

Add or update Firestore rules:

```text
users/{uid}: only request.auth.uid == uid
users/{uid}/profiles/{profileId}: only request.auth.uid == uid
users/{uid}/proposals/{proposalId}: only request.auth.uid == uid
users/{uid}/settings/{settingsId}: only request.auth.uid == uid
```

Rules should validate required ownership fields where stored, reject unknown
top-level user writes where possible, and deny unauthenticated access.

## Tests

- Unit test `AuthRepository` success and failure paths with fakes.
- Unit test path resolver output for a given user id.
- Update `FirestoreUserProfileRepository` tests to assert the user-scoped path.
- Add migration tests:
  - new profile exists: legacy profile is not copied.
  - new profile missing and legacy exists: profile is copied once.
  - no legacy profile: app creates or returns an empty profile state.
- Widget test auth loading and auth error shell states.
- Add Firestore security rule tests or a documented emulator test command.

## Acceptance Criteria

- No new feature writes to global `user_profiles/primary`.
- Existing profile UI still loads, edits, and saves a profile.
- A user id is available to all future persistence repositories.
- Firebase-disabled development mode still works.
- `flutter analyze` and affected tests pass.

## Out of Scope

- Email/password login.
- OAuth provider setup.
- Account linking.
- User-facing account management screens.
- Deleting user accounts.

