# Repository Guidelines

## Project Structure & Module Organization
- `lib/` — app code. Key dirs: `config` (DI, routes, theme, `AppConfig`), `view`, `viewmodel`, `service`, `use_case`, `model`, `utils`/`helpers`, `data`, `domain`. Entry: `lib/main.dart`.
- `test/` — unit/widget tests mirroring `lib/` (e.g., `test/utils/auth/token_sanitizer_test.dart`).
- `assets/` — images/logos declared in `pubspec.yaml`.
- `android/`, `ios/` — platform; `docs/` — documentation.

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Analyze lints/types: `flutter analyze`
- Format code: `dart format .` (run before committing)
- Run tests: `flutter test` (coverage: `flutter test --coverage`)
- Run app: `flutter run -d <device>` (e.g., `-d ios`, `-d android`)
- Build release: `flutter build apk --release` | `flutter build ios --no-codesign`

## Coding Style & Naming Conventions
- Lints: `flutter_lints` + `analysis_options.yaml` (e.g., `prefer_relative_imports`, `formatter.trailing_commas: preserve`). Use relative imports within `lib/`.
- Indentation: 2 spaces. Files `snake_case.dart`; classes `UpperCamelCase`; methods/vars `lowerCamelCase`.
- Organization: UI in `view/`, state in `viewmodel/`, domain in `use_case/`, adapters in `service/`, shared helpers in `utils/`/`helpers/`.

## Testing Guidelines
- Place tests under `test/` mirroring `lib/`; name files `*_test.dart`. Use `group()`/`test()` from `flutter_test`.
- Prioritize `utils`, `service`, `use_case`, and `viewmodel`. Add tests for bug fixes and new features.
- Keep tests hermetic (no real network); mock services where needed.

## Commit & Pull Request Guidelines
- Conventional Commits: `feat`, `fix`, `chore`, `refactor`, `docs` (optional scope: `feat(auth): ...`).
- Branch: `type/scope-description` (e.g., `feat/auth-login`).
- PR checklist: summary, linked issues (`Closes #123`), screenshots for UI changes, test plan; CI green (analyze/format/test).

## CI & Automation
- GitHub Actions runs on push/PR to `main`: analyze, format check, tests.
- Workflow file: `.github/workflows/ci.yml`. Run locally: `dart format --set-exit-if-changed . && flutter analyze && flutter test`.

## Release & Fastlane
- iOS Firebase distribution workflow: `.github/workflows/app_distribution_ios.yml` (runs on `develop` and manual dispatch).
- Fastlane lanes (iOS) live in `fastlane/Fastfile` (`ios deploy_firebase`). Plugins in `fastlane/Pluginfile`.
- Keep credentials in GitHub Secrets (e.g., `FIREBASE_APP_ID`, `FIREBASE_TOKEN`, `MATCH_*`). Never commit keys or provisioning files.

## Security & Configuration Tips
- Do not commit secrets or API keys. Base URLs live in `lib/config/app_config.dart`/`app_urls.dart`; toggle with `AppConfig.isProduction`.
- Android emulators reach host at `10.0.2.2` (handled in `AppConfig`). Keep `pubspec.yaml` assets in sync with `assets/`.
