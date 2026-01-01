# Proposal Writer

A Flutter app scaffold for generating proposals with OpenAI across iOS, Android, and Web.

## Prerequisites
- Flutter (stable channel)
- Chrome (for web development)

## Getting Started
```bash
flutter pub get
```

### Run (mobile)
```bash
flutter run
```

### Run (web)
```bash
flutter run -d chrome
```

## Environment Configuration
Secrets are never committed. Use `--dart-define` in CI/production and optionally `.env` locally.

### Preferred (CI/production)
```bash
flutter run \
  --dart-define=OPENAI_API_KEY=your_key \
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```

### Optional local `.env`
Create a `.env` file (ignored by git):
```ini
OPENAI_API_KEY=your_key
OPENAI_MODEL=gpt-4o-mini
OPENAI_BASE_URL=https://api.openai.com
MOCK_API=true
```

### Mock Mode
```bash
flutter run --dart-define=MOCK_API=true
```

## Testing
- Unit + widget tests (with coverage):
```bash
flutter test --coverage
```

- Integration tests (mock mode):
```bash
flutter test integration_test --dart-define=MOCK_API=true
```

## Architecture Overview
```
lib/
  core/          Failures, result, env, DI, constants
  data/          OpenAI client, DTOs, repository implementation
  domain/        Entities, repository interfaces, use cases
  presentation/  Screens, state/providers, widgets
```

### Adding a Feature
1. Add entities or use cases in `lib/domain/`.
2. Implement data access in `lib/data/`.
3. Wire providers in `lib/core/di/providers.dart`.
4. Build UI/state in `lib/presentation/`.

## Web Support
Ensure Chrome is installed and run:
```bash
flutter run -d chrome
```
