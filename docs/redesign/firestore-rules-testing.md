# Firestore Rules Validation

Phase 01 introduces user-owned Firestore paths:

```text
users/{uid}
users/{uid}/profiles/{profileId}
users/{uid}/proposals/{proposalId}
users/{uid}/settings/{settingsId}
```

Rules live in `firestore.rules` and are referenced by `firebase.json`.

## Emulator Smoke Command

After installing Firebase CLI and logging in, run:

```bash
firebase emulators:exec --only firestore --project <firebase-project-id> "flutter test test/unit/user_profile_repository_test.dart"
```

If Firebase CLI is not installed globally, use:

```bash
npx firebase-tools emulators:exec --only firestore --project <firebase-project-id> "flutter test test/unit/user_profile_repository_test.dart"
```

This is a rules-loading smoke command: the emulator must parse `firestore.rules`
successfully, then the app's user-scoped repository tests run. The Flutter tests
use `fake_cloud_firestore`, so they do not replace a future
`@firebase/rules-unit-testing` authorization suite.

For production, deploy the rules with:

```bash
firebase deploy --only firestore:rules --project <firebase-project-id>
```
