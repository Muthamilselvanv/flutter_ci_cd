# Flutter environments and CI/CD practice

This project demonstrates three separate configuration layers:

1. Dart defines inject compile-time values into Dart code.
2. Android product flavors create distinct native app variants.
3. GitHub Actions supplies CI environment variables to `--dart-define`.

## 1. Dart defines only

`lib/config/app_config.dart` reads `APP_ENV` and `API_BASE_URL`. With no flags,
the app displays its development defaults.

Run the lesson command in PowerShell:

```powershell
flutter run --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging.example.com
```

The screen will display:

```text
Environment: staging
API: https://staging.example.com
```

`String.fromEnvironment` is a compile-time lookup. It does not read Windows
environment variables or `.env` by itself.

## 2. CI environment

`.github/workflows/flutter_ci.yml` reads `API_BASE_URL` and `WEB_BASE_URL` from
the selected GitHub Environment. Its build command passes those values into the
Flutter compiler:

```text
GitHub Actions env -> --dart-define -> AppConfig -> controller -> screen
```

Pull requests to `main`, `develop`, or `staging` run formatting, analysis, and
tests without building an app. Builds are created only when someone selects
**Actions > Flutter CI/CD > Run workflow**, or pushes a `v*` production tag.

Create `development`, `staging`, and `production` under **Repository Settings >
Environments**. Add these environment variables to each environment:

```text
API_BASE_URL
WEB_BASE_URL
```

Manual `development` and `staging` runs produce APKs. A manual `production` run
or a tag such as `v1.0.0` produces an AAB. Add required reviewers to the
production GitHub Environment if releases need approval.

## 3. Android flavors

`android/app/build.gradle.kts` defines `dev`, `staging`, and `production`.
Run each flavor with matching Dart configuration:

```powershell
flutter run --flavor dev --dart-define=APP_ENV=development --dart-define=API_BASE_URL=https://gulftest.traitsolutions.in/RestApi/app_api --dart-define=WEB_BASE_URL=https://gulftest.traitsolutions.in/RestApi/web_api/
flutter run --flavor staging --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging.example.com --dart-define=WEB_BASE_URL=https://staging.example.com/web_api/
flutter run --flavor production --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.example.com --dart-define=WEB_BASE_URL=https://example.com/web_api/
```

The flavor controls the native Android identity (application ID/name/build
variant). Dart defines control values available inside Flutter. They are
independent, so keep them paired correctly in commands and CI.

## `.env` and `.env.example`

`.env.example` is a safe, committed template. Copy it when setting up locally:

```powershell
Copy-Item .env.example .env
```

`.env` is ignored by Git. It is not consumed by this app because this exercise
uses Dart defines only. A dotenv package could load it at runtime, while a shell
script could translate it into Dart defines; neither behavior is automatic.

Never store real secrets in Dart defines or a mobile `.env`: compiled mobile
apps can be inspected. Keep secrets on a backend or in a CI secret store and
only inject non-secret app configuration such as URLs and environment names.
