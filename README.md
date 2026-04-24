# Proposal Writer

Proposal Writer is an open-source Flutter app for generating tailored proposals
with OpenAI and storing reusable user profile data in Firestore.

It is designed as a practical cross-platform starter for teams that want:
- AI-assisted proposal generation
- reusable profile context such as CV, portfolio links, education, and bio
- a clean Flutter architecture with Riverpod-based state management
- CI-ready development and test workflows

## Features

- Generate proposal drafts with OpenAI
- Ask follow-up clarification questions before generating the final proposal
- Save a reusable profile in Firestore, including:
  - CV or resume text
  - professional summary
  - portfolio links
  - education history
  - profile image URL
- Inject saved profile context into proposal generation automatically
- Run in mock mode for local development and automated tests
- Support Flutter mobile, web, and desktop targets from one codebase

## Stack

- Flutter
- Dart
- Riverpod
- Dio
- Firebase Core
- Cloud Firestore
- GitHub Actions

## Project Status

This repository is suitable for public GitHub publication as an open-source
project scaffold. It intentionally does not commit secrets or Firebase config
files.

Current Firestore storage uses a single document:

```text
user_profiles/primary
```

If you want true multi-user storage, add Firebase Authentication and switch the
document id from `primary` to `currentUser.uid`.

## Quick Start

### Prerequisites

- Flutter on the stable channel
- Chrome for web development
- A Firebase project if you want Firestore-backed profile storage

### Install

```bash
flutter pub get
```

### Run

Mobile:

```bash
flutter run
```

Web:

```bash
flutter run -d chrome
```

## Configuration

Secrets are not committed. Use `--dart-define` in CI or production and an
ignored `.env` file for local development if needed.

### OpenAI

Required for live proposal generation:

```ini
OPENAI_API_KEY=your_key
OPENAI_MODEL=gpt-5-mini
OPENAI_BASE_URL=https://api.openai.com
```

### Firebase / Firestore

Required if you want the profile editor to save data to Firestore:

```ini
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_MACOS_APP_ID=your_macos_app_id
FIREBASE_WINDOWS_APP_ID=your_windows_app_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

If Firebase is not configured, the app still runs, but profile saving is
disabled.

### Local `.env` Example

```ini
OPENAI_API_KEY=your_key
OPENAI_MODEL=gpt-5-mini
OPENAI_BASE_URL=https://api.openai.com
MOCK_API=false

FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_MACOS_APP_ID=your_macos_app_id
FIREBASE_WINDOWS_APP_ID=your_windows_app_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

### Mock Mode

Use mock mode when you want to work without calling OpenAI:

```bash
flutter run --dart-define=MOCK_API=true
```

## Firestore Data Model

The profile form persists the following fields in Firestore:

- `fullName`
- `email`
- `professionalTitle`
- `about`
- `cvText`
- `portfolioLinks`
- `education`
- `profileImageUrl`

`profileImageUrl` is stored as a string. If you want to store the actual image
asset, upload it to Firebase Storage and save the URL or storage path in
Firestore.

## Development

Run analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

Run integration tests in mock mode:

```bash
flutter test integration_test -d chrome --dart-define=MOCK_API=true
```

Build the web app:

```bash
flutter build web
```

## Architecture

```text
lib/
  core/          App configuration, failures, DI, shared constants
  data/          OpenAI and Firestore repository implementations
  domain/        Entities, repository contracts, use cases
  presentation/  Screens, state, and widgets
```

## CI

GitHub Actions runs:

- formatting checks
- static analysis
- unit and widget tests
- integration tests in mock mode
- web build validation

## Open Source Notes

Before publishing publicly, you should still do these repo-owner steps:

- review git history for accidentally committed secrets
- configure Firebase Authentication if you need per-user data isolation
- set Firestore security rules for your production project
- add the final GitHub repo description, topics, and social preview image
- decide whether MIT is the license you want long term

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before
opening a pull request.

## Security

If you discover a security issue, follow the process in [SECURITY.md](SECURITY.md).

## Code of Conduct

This project follows the standards in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

This repository is licensed under the [MIT License](LICENSE).
