# Contributing

## Scope

This project accepts improvements to product behavior, code quality,
documentation, tests, and developer tooling.

## Before You Start

- Search existing issues and pull requests first.
- Keep changes focused. Large mixed-scope PRs are harder to review.
- Open an issue before starting a major feature, architecture change, or
  breaking change.

## Local Setup

```bash
flutter pub get
flutter analyze
flutter test
```

If you need the full browser-based test flow:

```bash
flutter test integration_test -d chrome --dart-define=MOCK_API=true
```

## Development Expectations

- Follow the existing project structure in `lib/core`, `lib/data`,
  `lib/domain`, and `lib/presentation`.
- Do not commit secrets, `.env` files, Firebase config files, or private keys.
- Add or update tests for meaningful behavior changes.
- Keep docs in sync when configuration, workflow, or architecture changes.
- Prefer small, reviewable pull requests.

## Pull Request Checklist

- The code builds locally.
- `flutter analyze` passes.
- `flutter test` passes.
- Documentation is updated where needed.
- No secrets or generated local config files were added.

## Commit Guidance

Clear, scoped commit messages are preferred. Examples:

- `feat: add Firestore-backed user profile repository`
- `docs: rewrite README for open source publication`
- `test: cover profile persistence flow`

## Review Process

Maintainers may ask for:

- narrower scope
- additional tests
- clearer naming or architecture boundaries
- documentation updates

Unreviewed or abandoned PRs may be closed to keep the queue clean.
