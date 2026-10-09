# Flutter environments and CI/CD practice

The complete pre-production workflow, security, signing, environment, artifact,
and release instructions are documented in
[`docs/ci-cd-guide.md`](docs/ci-cd-guide.md). Google Play deployment is
intentionally not implemented yet.

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

Build workflows read `API_BASE_URL` and `WEB_BASE_URL` from the selected GitHub
Environment and pass those values into the Flutter compiler:

```text
GitHub Actions env -> --dart-define -> AppConfig -> controller -> screen
```

Pull requests and pushes to `main` run formatting, analysis, and tests without
building an app. A testing APK is created manually through **Actions > Build
Testing APK > Run workflow**. Production artifacts are created only by pushing
a `v*` tag.

Create `development`, `staging`, and `production` under **Repository Settings >
Environments**. Add these environment variables to each environment:

```text
API_BASE_URL
WEB_BASE_URL
```

Manual `development` and `staging` runs produce APKs. A tag such as `v1.0.0`
produces a production APK and AAB. Add required reviewers to the production
GitHub Environment if releases need approval.

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

## CI, testing APK, and release workflows

The workflows have separate responsibilities:

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `flutter_ci.yml` | Pull request to `main`, or push to `main` | Format, analyze, and test |
| `flutter_test_apk.yml` | Manual **Run workflow** action | Build a development/staging APK for testers |
| `flutter_release.yml` | Push a tag matching `v*` | Test and build production APK/AAB artifacts |

Create GitHub Environments named `development`, `staging`, and `production`.
In each environment, add variables named `API_BASE_URL` and `WEB_BASE_URL`.
The manual testing workflow intentionally cannot select production.

To obtain a testing APK, open the repository on GitHub, select **Actions**,
select **Build Testing APK**, choose **Run workflow**, select the environment
and build mode, and run it. Download the APK from the run's **Artifacts** area.

Before a release, update `version:` in `pubspec.yaml`, commit and push the
changes, wait for Flutter CI to pass, and then create the version tag:

```powershell
git add pubspec.yaml .github/workflows README.md
git commit -m "ci: separate validation, testing APK, and release workflows"
git push origin main
git tag -a v1.0.1 -m "Add separate testing and release workflows"
git tag
git push origin v1.0.1
```

`actions/upload-artifact` stores build files on the workflow run. It does not
create a public GitHub Release page. Also replace the current debug signing
configuration with a protected release keystore before publishing to a store.
