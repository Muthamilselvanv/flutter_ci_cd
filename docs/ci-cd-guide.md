# Flutter CI/CD guide

This project stops at a signed, verified, downloadable production package. It
does not deploy to Google Play.

## Architecture

```text
feature branch
      |
      v
pull request to dev/main
      |
      +--> format ---------+
      +--> analyze --------+--> quality/security gate
      +--> tests+coverage -+
      +--> secret scan ----+
      +--> dependency review
                              |
                              v
                       merge is allowed

manual testing request
      |
      v
validate + security --> dev/staging APK --> GitHub artifact

vMAJOR.MINOR.PATCH tag or confirmed manual release
      |
      v
verify main + version --> quality/security --> production approval
      |
      v
restore signing --> signed APK/AAB --> verify signatures
      |
      v
versioned package + checksums --> GitHub artifact --> manual QA
      |
      v
STOP (no Google Play deployment yet)
```

## Workflow responsibilities

| File | Trigger | Responsibility |
| --- | --- | --- |
| `flutter_ci.yml` | PR/push to `dev` or `main`, manual | Parallel quality/security gates and post-merge build verification |
| `flutter_test_apk.yml` | Manual | Validated development or staging APK for testers |
| `flutter_release.yml` | `v*` tag or confirmed manual run | Validate version/source, approve, sign, verify, and retain production APK/AAB |

## Branch strategy

The repository currently uses `dev` and `main`, so the recommended flow is:

```text
feature/* -> pull request -> dev -> pull request -> main
```

- `feature/*`: isolated work.
- `dev`: integration and team testing.
- `main`: stable and eligible for release tags.
- Staging is currently a GitHub Environment, not a required Git branch.

Protect `dev` and `main` with pull requests. Require the **Enforce quality and
security gate** status check. Protect `main` more strictly by disallowing direct
pushes and requiring reviews.

## Test and coverage strategy

Fast unit and widget tests run on every PR and protected-branch push. Coverage
is generated at `coverage/lcov.info`. The initial line threshold is 50%, based
on the measured 51.35% baseline. Increase it gradually as tests are added.

Run locally:

```powershell
flutter test --coverage --reporter expanded
dart run tool/check_coverage.dart 50
```

One hundred percent coverage is not automatically good: assertions can be
weak, generated code may distort the number, and important behavior can remain
untested. Coverage is a signal, not proof of correctness.

Integration tests are intentionally not in hosted CI yet. Add a small emulator
smoke suite only after tests use deterministic mock or controlled staging data.

## Quality gates

These checks block downstream builds:

- Dart formatting.
- Flutter analysis.
- Unit/widget tests.
- Minimum line coverage.
- Secret scan.
- High-severity vulnerable dependencies introduced by a pull request.

Build jobs use `needs:` so they cannot start when an upstream gate fails.
Warnings that do not establish broken or unsafe behavior should remain
informational rather than making the pipeline noisy and untrusted.

## DevSecOps and action security

DevSecOps integrates security into ordinary development instead of waiting
until release. This project uses:

- Gitleaks v3 to scan Git history for secrets.
- A tracked-file policy that rejects `.env`, keystores, `key.properties`, and
  service-account JSON files.
- GitHub dependency review on pull requests, blocking newly introduced high or
  critical vulnerabilities.
- Dependabot for weekly Dart and GitHub Actions update pull requests.
- Workflow-level `contents: read` permissions.
- Immutable commit pins for every external GitHub Action. The trailing version
  comments stay readable, and Dependabot proposes reviewed pin updates.

CodeQL is not added because GitHub CodeQL does not provide first-class Dart
analysis for this small Flutter project. Trivy is not added because this repo
does not currently contain container images or infrastructure manifests.

Review Dependabot PRs instead of merging blindly:

- Patch (`1.2.3 -> 1.2.4`): usually fixes, still test.
- Minor (`1.2.3 -> 1.3.0`): backward-compatible features in SemVer, test fully.
- Major (`1.2.3 -> 2.0.0`): may break APIs; read migration notes and upgrade
  deliberately.

## Configuration and secrets

Create GitHub Environments:

```text
development
staging
production
```

Add non-secret variables to every appropriate environment:

```text
API_BASE_URL
WEB_BASE_URL
```

Add these encrypted secrets to `production` only:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

Generate a base64 keystore value in PowerShell:

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes('C:\secure\upload-keystore.jks')
) | Set-Clipboard
```

Do not print secrets. Avoid shell tracing such as `set -x`: it can echo commands
and expanded values. GitHub masking is a safety net, not a guarantee; derived,
encoded, split, or transformed values may not be masked.

`.env` is ignored and remains local. `.env.example` documents names and safe
sample values. CI uses GitHub variables and `--dart-define` directly, so it does
not need to create a persistent `.env` file.

## Production protection and signing

Configure the `production` GitHub Environment with required reviewers. The
release build job pauses before receiving production variables and signing
secrets until a reviewer approves it.

The workflow restores the keystore only on its temporary runner, writes
`android/key.properties`, builds, verifies both signatures, uploads artifacts,
and removes signing files. The runner is later discarded.

The Gradle configuration deliberately falls back to debug signing only for
local learning builds when `key.properties` is absent. The release workflow
does not allow this fallback because it fails before building if any signing
secret is missing.

## Version and release strategy

`pubspec.yaml` uses:

```text
MAJOR.MINOR.PATCH+BUILD_NUMBER
```

Example:

```text
1.2.3+45
```

- `1`: incompatible/breaking release.
- `2`: backward-compatible features.
- `3`: backward-compatible fixes.
- `45`: monotonically increasing Android version code.

For a tag release, the tag must match the visible pubspec version:

```text
pubspec: 1.2.3+45
tag:     v1.2.3
```

The release commit must belong to `main`. The workflow also accepts a manual
release tag input, requires an explicit confirmation checkbox, and still
checks `main`, version format, quality, security, environment approval, and
signing.

## Artifacts

Testing artifacts are retained for 14 days. Production artifacts are retained
for 90 days and contain:

```text
app-production-v1.2.3+45.apk
app-production-v1.2.3+45.aab
SHA256SUMS.txt
release-info.txt
```

Artifacts are run outputs stored by GitHub, not files committed to Git. The
checksum detects accidental or malicious file changes after download.

## Common failures

| Failure | Likely cause | First check |
| --- | --- | --- |
| Format job fails | Dart files need formatting | `dart format lib test tool` |
| Analyzer fails | Type/lint/import problem | `flutter analyze` |
| Coverage fails | Coverage dropped below 50% | Open `coverage/lcov.info`, add meaningful tests |
| Gitleaks fails | Credential-like value in history | Rotate real secret first; inspect finding |
| Dependency review fails | PR introduces known vulnerability | Upgrade/remove dependency or document approved exception |
| Environment validation fails | GitHub variables absent | Environment variables in repository Settings |
| Signing restore fails | Invalid/missing base64 or passwords | Production Environment secrets |
| Tag validation fails | Tag and pubspec differ | Match `vX.Y.Z` to `X.Y.Z+N` |
| Main verification fails | Tagged commit is not on main | Merge through main before tagging |
| Artifact upload fails | Flutter output path changed/build failed | Inspect build output and expected flavor path |

## Future — Google Play deployment

No Play deployment code is present. When access exists, the next stage needs:

- A real, stable Android application ID (not `com.example...`).
- An application created in Google Play Console.
- Play App Signing configuration.
- Google Cloud service account with minimum necessary Play permissions.
- Google Play Android Developer API access.
- The service-account JSON stored as a protected GitHub secret.
- An upload job that depends on the existing signed release artifact and uses
  the `internal` track first.

The future flow will be:

```text
current signed release artifact
        -> production approval
        -> Google Play Internal Testing
```

It must reuse the already tested artifact instead of rebuilding different bits.
