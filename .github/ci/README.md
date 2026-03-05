# CI Configuration for SDK Validation

This folder contains the source-of-truth config for the manual `SDK Validation` workflow.

Main files:

- Workflow: `.github/workflows/sdk-validation.yml`
- Config: `.github/ci/ci-run-config.json`
- Helpers: `scripts/ci/sdk_validation/`

The workflow is manual-only (`workflow_dispatch`). There are no automatic triggers for pull requests or pushes.

## Workflow Shape

There is one workflow, `SDK Validation`, with four user-facing validation flows controlled by workflow inputs:

- `build_sdk_targets`
- `build_test_app`
- `run_tests`
- `lint_pods`

Internally, the workflow also has a technical `Prepare CI config` job that validates inputs and computes effective matrices before the validation jobs start.

Default manual profile:

- `build_sdk_targets = true`
- `build_test_app = true`
- `run_tests = true`
- `lint_pods = false`

## Validation Flows

### `build_sdk_targets`

What it does:

- runs SwiftPM SDK library target builds across `build_matrix`
- builds the iOS package scheme `Adapty-Package` on the primary `sdk_tests` entry (`runner + xcode`)
- runs a separate one-Xcode macOS SDK build on `sdk_tests.runner` + `sdk_tests.xcode`

Inputs that affect it:

- `build_sdk_targets`
- `build_matrix_override_json`

Behavior:

- strict failure
- `build_matrix` must include the primary `sdk_tests` entry (`runner + xcode`)

### `build_test_app`

What it does:

- builds `AdaptyRecipes-SwiftUI`
- runs only on the primary `sdk_tests` entry (`runner + xcode`), even if `build_matrix` contains more entries
- writes a CI-specific `AppConstants.swift` before `xcodebuild`

Inputs that affect it:

- `build_test_app`
- `build_matrix_override_json`

Behavior:

- uses the single primary `sdk_tests` entry filtered from `build_matrix`
- strict failure

### `run_tests`

What it does:

- runs `swift test` using `sdk_tests_matrix`

Inputs that affect it:

- `run_tests`
- `sdk_tests_matrix_override_json`

Behavior:

- strict failure
- no whitelist support

### `lint_pods`

What it does:

- runs `pod lib lint` for published podspecs

Inputs that affect it:

- `lint_pods`

Behavior:

- strict failure
- no whitelist support
- runs on `sdk_tests.runner` + `sdk_tests.xcode`

## Manual Run Inputs

### Boolean flags

- `build_sdk_targets`: enable the SDK build flow
- `build_test_app`: enable the test app build flow
- `run_tests`: enable the `swift test` flow
- `lint_pods`: enable the CocoaPods lint flow

At least one of these flags must be `true`.

### JSON overrides

- `build_matrix_override_json`: optional override for SDK build flow and primary entry selection for the test app
- `sdk_tests_matrix_override_json`: optional override for the `swift test` matrix; entries may use `informational: true` to make a test run non-blocking

## Validation Rules

- Boolean defaults in `workflow_dispatch` must stay in sync with `.github/ci/ci-run-config.json`.
- `Prepare CI config` fails if all four boolean flags are `false`.
- Matrix override JSON must be a non-empty array or an object with `include[]`.
- Matrix entries must be unique by `runner + xcode`.
- If `build_sdk_targets=true` or `build_test_app=true`, `build_matrix` must include the primary `sdk_tests` entry (`runner + xcode`).
- `sdk_tests_matrix_override_json` does not require the primary `sdk_tests` entry; it can be used for custom test-only runs.

## Xcode Selection Behavior

- Matrix jobs use `setup-xcode` for requested versions.
- If a matrix entry is `informational: true` and Xcode is unavailable, that entry is skipped with a warning.
- If a matrix entry is `informational: false` and Xcode is unavailable, that entry fails.
- For matrix jobs, `informational: true` also means the entry uses `continue-on-error` and does not block the whole workflow if the build/test command fails.
- One-Xcode jobs (`SDK macOS build`, `CocoaPods lint`) fail if the configured Xcode is unavailable.
- iOS-specific steps (`Adapty-Package` and `AdaptyRecipes-SwiftUI`) run only on the primary `sdk_tests` entry (`runner + xcode`).

## Manual Run Guide

### GitHub UI

1. Open `Actions`.
2. Select `SDK Validation`.
3. Click `Run workflow`.
4. Choose the branch in `Use workflow from`.
5. Leave the default profile or override flags/JSON inputs.
6. Click `Run workflow`.

Artifacts:

- `swift-build-products-log-...`
- `demo-build-log-...`
- `swift-build-macos-log-...`
- `pod-lib-lint-log-...`
- `sdk-tests-log-...`

### GitHub CLI (`gh`)

Run full default profile:

```bash
gh workflow run "SDK Validation" --ref master
```

Run only SDK builds on one Xcode:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=true \
  -f build_test_app=false \
  -f run_tests=false \
  -f lint_pods=false \
  -f build_matrix_override_json='[{"runner":"macos-15","xcode":"26.2","informational":false}]'
```

Run only test app build:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=true \
  -f run_tests=false \
  -f lint_pods=false
```

Run only tests:

```bash
gh workflow run "SDK Validation" --ref master \
  -f build_sdk_targets=false \
  -f build_test_app=false \
  -f run_tests=true \
  -f lint_pods=false
```
