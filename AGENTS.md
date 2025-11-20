# Repository Guidelines

## Project Structure & Module Organization
The Flutter app lives under `lib/`, organized by feature-centric layers: dependency injection and routing in `lib/config`, presentation in `lib/view`, stateful logic in `lib/viewmodel`, domain logic under `lib/use_case` and `lib/domain`, and integration adapters in `lib/service` and `lib/data`. Shared helpers belong to `lib/utils` or `lib/helpers`. Entry point: `lib/main.dart`. Widget/unit tests mirror this layout under `test/` (e.g., `test/utils/auth/token_sanitizer_test.dart`). Assets such as icons or logos are stored in `assets/` and must be declared in `pubspec.yaml`. Platform projects sit in `android/` and `ios/`, while additional reference docs are in `docs/`.

## Build, Test, and Development Commands
- `flutter pub get` — install/update Dart and Flutter dependencies.
- `flutter analyze` — enforce lint rules and catch type issues.
- `dart format .` — format Dart files (run before every commit).
- `flutter test` or `flutter test --coverage` — execute unit/widget suites, optionally collecting coverage.
- `flutter run -d <device>` — launch the app locally (`-d ios`, `-d android`).
- Release builds: `flutter build apk --release` and `flutter build ios --no-codesign`.

## Coding Style & Naming Conventions
Follow `flutter_lints` plus `analysis_options.yaml`. Use 2-space indentation, snake_case filenames (`user_profile_view.dart`), UpperCamelCase classes, and lowerCamelCase members. Prefer relative imports inside `lib/` to satisfy the `prefer_relative_imports` rule. Preserve trailing commas so `dart format` keeps multi-line layouts stable.

## Testing Guidelines
Write hermetic tests with `flutter_test`, mirroring the `lib/` structure and naming files `*_test.dart`. Prioritize coverage for utilities, services, use cases, and viewmodels. Mock network or platform integrations; never hit real endpoints. Run `flutter test --coverage` locally before feature branches merge.

## Commit & Pull Request Guidelines
Commits follow Conventional Commits (e.g., `feat/auth-login`, `fix: correct token refresh`). Branch names adopt `type/scope-description`. Pull requests should summarize changes, link issues (`Closes #123`), attach screenshots for UI updates, and document the test plan. CI on GitHub Actions runs `dart format --set-exit-if-changed . && flutter analyze && flutter test`; ensure it passes before requesting review.

## Security & Configuration Tips
Never commit secrets or API keys. Environment-specific URLs belong in `lib/config/app_config.dart` or `app_urls.dart`, toggled via `AppConfig.isProduction`. Android emulators reach the host backend via `10.0.2.2` (already handled in config). Keep `assets/` declarations synchronized with `pubspec.yaml`, and store Fastlane or Firebase credentials exclusively in GitHub Secrets (`FIREBASE_APP_ID`, `MATCH_*`, etc.).
