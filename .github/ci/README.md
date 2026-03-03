# CI Configuration for SDK Validation

This folder contains the source-of-truth config for the CI workflow:

- Workflow: `.github/workflows/sdk-validation.yml`
- Config: `.github/ci/ci-run-config.json`
- Build/test log validator: `scripts/ci/validate_demo_build.sh`

## What Runs Automatically

- `pull_request` (`opened`, `reopened`, `synchronize`, `ready_for_review`): default PR pipeline
  - SDK build matrix (`swift build` for all library targets + iOS package build)
  - test app build matrix (`AdaptyRecipes-SwiftUI`)
  - one-Xcode macOS SDK build
  - SDK tests matrix (`swift test`)
- `workflow_dispatch`: manual run with per-step toggles and optional JSON overrides
- `pull_request` note: CocoaPods lint is disabled for PR auto-runs (`lint_pods=false`)

Note: there is no automatic `push` trigger for this workflow.

## Config File (`ci-run-config.json`)

`schema_version: 2` config keys:

- `build_sdk_targets` (`bool`): default enable SDK matrix build + macOS SDK build
- `build_test_app` (`bool`): default enable test app matrix build
- `run_tests` (`bool`): default enable `swift test` matrix
- `lint_pods` (`bool`): default disable CocoaPods lint job (can be enabled in manual runs)
- `build_errors_whitelist` (`list`): allowlist for test app build failures only
- `test_errors_whitelist` (`list`): allowlist for `swift test` failures
- `build_matrix` (`list`): Xcode matrix for SDK/test-app jobs
- `sdk_tests` (`object`): runner/Xcode for one-Xcode jobs (`macOS build`, `pod lib lint`)
- `sdk_tests_matrix` (`list`): Xcode matrix for `swift test`

Whitelist rule format:

- string message
- object `{ "message": string, "file"?: string, "line"?: number }`

Matching rules:

- `message` exact match
- `file` exact path or suffix path match
- `line` exact match (allowed only with `file`)

## Input Defaults Sync Rule

Boolean defaults are duplicated in two places by design:

- `workflow_dispatch` input defaults (GitHub UI)
- `.github/ci/ci-run-config.json` boolean values

`prepare_config` validates these defaults are identical and fails CI if they diverge.

## Xcode Selection Behavior

- Matrix jobs use `setup-xcode` for requested versions.
- If matrix entry is `informational: true` and Xcode is unavailable, that entry is skipped with warning.
- If matrix entry is `informational: false` and Xcode is unavailable, that entry fails.
- One-Xcode jobs (`SDK macOS build`, `CocoaPods lint` when enabled) fail when configured Xcode is unavailable.
- Test app build does not patch placeholders with `sed`; CI writes a dedicated `AppConstants.swift` with dummy values before `xcodebuild`.

## Manual Run Inputs (`workflow_dispatch`)

Boolean toggles (GitHub UI pickers):

- `build_sdk_targets`
- `build_test_app`
- `run_tests`
- `lint_pods`

Text JSON overrides:

- `build_errors_whitelist`: optional whitelist override for test app build
- `test_errors_whitelist`: optional whitelist override for `swift test`
- `build_matrix_override_json`: optional build matrix override (array or `{ "include": [...] }`)
- `sdk_tests_matrix_override_json`: optional test matrix override (array or `{ "include": [...] }`)

Validation rules:

- At least one toggle must be `true`.
- Matrix override JSON must contain at least one matrix entry.
- Matrix entries must be unique by `runner + xcode`.
- Empty whitelist input means "use values from `ci-run-config.json`".

## Manual Run Guide for QA

### Run via GitHub UI (step-by-step)

1. Open repository on GitHub.
2. Go to `Actions`.
3. Select workflow `SDK Validation`.
4. Click `Run workflow`.
5. In `Use workflow from`, select the branch.
6. Configure boolean toggles:
   - `build_sdk_targets`: run SDK matrix + iOS package + macOS SDK build.
   - `build_test_app`: run test app matrix build.
   - `run_tests`: run `swift test` matrix.
   - `lint_pods`: run `pod lib lint`.
7. (Optional) Fill JSON override fields:
   - `build_errors_whitelist`
   - `test_errors_whitelist`
   - `build_matrix_override_json`
   - `sdk_tests_matrix_override_json`
8. Click `Run workflow`.
9. Wait for jobs:
   - `SDK build (Xcode ...)`
   - `Test app build (Xcode ...)`
   - `SDK macOS build`
   - `CocoaPods lint`
   - `SDK tests (Xcode ...)`
10. Open artifacts/logs:
   - `swift-build-products-log-...`
   - `demo-build-log-...`
   - `swift-build-macos-log-...`
   - `pod-lib-lint-log-...`
   - `sdk-tests-log-...`

### Run via GitHub CLI (`gh`)

Run from repository root with authenticated CLI (`gh auth status`).

- Run full workflow using defaults from config:

```bash
gh workflow run "SDK Validation" --ref master
```

- Run only SDK builds on one Xcode:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=true \
  -f build_test_app=false \
  -f run_tests=false \
  -f lint_pods=false \
  -f build_matrix_override_json='[{"runner":"macos-15","xcode":"26.2","informational":false}]'
```

- Run only test app build:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=true \
  -f run_tests=false \
  -f lint_pods=false
```

- Run only tests:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=false \
  -f run_tests=true \
  -f lint_pods=false
```

- Run tests with whitelist override:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=false \
  -f run_tests=true \
  -f lint_pods=false \
  -f test_errors_whitelist='[{"message":"Some known test error"}]'
```

- Run test app build with whitelist override:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=true \
  -f run_tests=false \
  -f lint_pods=false \
  -f build_errors_whitelist='[{"message":"Some known build error"}]'
```

## Whitelist Scope

- `build_errors_whitelist` is applied only to test app build (`xcodebuild` in `Test app build` matrix job).
- SDK build steps (`swift build` targets, iOS package build, macOS SDK build) are strict and never use build whitelist.
- `test_errors_whitelist` is applied only to `swift test` logs.
