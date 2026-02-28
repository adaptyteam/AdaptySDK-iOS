# CI Configuration for AdaptyRecipes

This folder contains the source-of-truth config for the reusable CI workflow:

- Workflow: `.github/workflows/ci-adaptyrecipes.yml`
- Config: `.github/ci/demo-build-config.json`
- Build/test log validator: `scripts/ci/validate_demo_build.sh`

## What Runs Automatically

- `push` (`master`, `release/*`): matrix job with SDK `swift build` (all library targets derived from `Package.swift` library products) + demo `xcodebuild`, plus one-Xcode macOS SDK `swift build` and one-Xcode `pod lib lint`
- `pull_request` (`opened`, `reopened`, `synchronize`, `ready_for_review`): matrix job with SDK `swift build` (all library targets derived from `Package.swift` library products) + demo `xcodebuild`, one-Xcode macOS SDK `swift build`, one-Xcode `pod lib lint`, plus SDK `swift test` matrix
- `workflow_dispatch`: manual selection of builds/tests, with optional JSON overrides

## Xcode Selection Behavior

- Demo matrix jobs try to select configured Xcode with `setup-xcode`
- If Xcode is unavailable:
  - `informational: true` entry finishes successfully with warning and no build/test step execution
  - `informational: false` entry fails the job
- One-Xcode macOS SDK build uses `sdk_tests.runner` + `sdk_tests.xcode` and fails when Xcode is unavailable
- macOS SDK build compiles all SDK library targets with `swift build --triple arm64-apple-macosx11.0`
- One-Xcode CocoaPods lint uses `sdk_tests.runner` + `sdk_tests.xcode` and fails when Xcode is unavailable
- CocoaPods lint checks published podspecs (`Adapty`, `AdaptyUI`, `AdaptyPlugin`) with `--allow-warnings --skip-tests`, resolving local ancillary podspecs via `--include-podspecs`
- SDK tests run on `sdk_tests_matrix` entries:
  - required entries (`informational: false`) fail on unavailable Xcode or test failures
  - informational entries (`informational: true`) warn and skip when Xcode is unavailable
  - default matrix includes `26.2` (required) and `16.0` (required)

## Edit Xcode Matrix via Config File

Update `.github/ci/demo-build-config.json`:

- `build_matrix` controls matrix runs that compile all SDK library targets derived from `Package.swift` library products and then build the demo app
- `sdk_tests` controls Xcode/runner for one-Xcode macOS SDK build and one-Xcode `pod lib lint`
- `sdk_tests_matrix` controls multi-Xcode `swift test` runs
- `ignored_error_messages` is unused for demo builds, must stay `[]`, and is validated in `prepare_config`
- `ignored_test_error_messages` is an allowlist for accepted `swift test` failures

## Manual Overrides (`workflow_dispatch`)

You can override config values for a single run without committing changes.

Inputs:

- `run_demo_builds`: `true` or `false`
- `run_sdk_tests`: `true` or `false`
- `matrix_override_json`: optional JSON
- `ignored_test_errors_override_json`: optional JSON

At least one of `run_demo_builds` / `run_sdk_tests` must be `true`.
`matrix_override_json` is a workflow input field in GitHub Actions UI (not a file).
`matrix_override_json` cannot be an empty array (`[]`); it must contain at least one matrix entry.
Matrix entries must be unique by `runner + xcode` pair.
Manual overrides are applied only to enabled jobs:
- build overrides are applied only when `run_demo_builds=true`
- test ignored-errors override is applied only when `run_sdk_tests=true`

### Matrix Override Examples

Use a JSON array:

```json
[
  { "runner": "macos-15", "xcode": "26.2", "informational": false }
]
```

Or object with `include`:

```json
{
  "include": [
    { "runner": "macos-15", "xcode": "26.2", "informational": false },
    { "runner": "macos-15", "xcode": "16.0", "informational": false }
  ]
}
```

### Ignored Test Errors Override Example

```json
[
  {
    "message": "extra argument 'profileId' in call",
    "file": "Tests/Placements/FallbackTests.swift",
    "line": 67
  },
  {
    "message": "missing arguments for parameters 'userId', 'requestLocale' in call",
    "file": "Tests/Placements/FallbackTests.swift",
    "line": 67
  }
]
```

## Manual Run Guide for QA

This section is for manual CI runs when validating a branch before merge/release.

### Run via GitHub UI (step-by-step)

1. Open GitHub repository page.
2. Go to `Actions`.
3. Select workflow `CI AdaptyRecipes`.
4. Click `Run workflow`.
5. In `Use workflow from`, pick the target branch (for example `master` or your release branch).
6. Fill inputs:
   - `run_demo_builds`: run matrix SDK/demo builds (`true` for regular full validation, `false` to skip builds).
   - `run_sdk_tests`: run `swift test` matrix (`true` to run tests, `false` to skip tests).
   - `matrix_override_json`: optional custom build matrix JSON (use when you need only one Xcode build run).
     Example:
     ```json
     [{"runner":"macos-15","xcode":"26.2","informational":false}]
     ```
   - `ignored_test_errors_override_json`: optional override for allowed `swift test` failures.
     Example:
     ```json
     [{"message":"extra argument 'profileId' in call","file":"Tests/Placements/FallbackTests.swift","line":67}]
     ```
7. Click `Run workflow`.
8. Wait for jobs to appear:
   - build matrix jobs: `Demo build (Xcode ...)`
   - macOS compile job: `SDK macOS build`
   - CocoaPods job: `CocoaPods lint`
   - test matrix jobs: `SDK tests (Xcode ...)`
9. Open run artifacts:
   - `demo-build-log-...`
   - `swift-build-products-log-...`
   - `swift-build-macos-log-...`
   - `pod-lib-lint-log-...`
   - `sdk-tests-log-...`

### Run via GitHub CLI (`gh`)

Run from repository root with authenticated GitHub CLI (`gh auth status`).

- Run full default workflow:
  ```bash
  gh workflow run "CI AdaptyRecipes" --ref master
  ```

- Run builds only on one Xcode:
  ```bash
  gh workflow run "CI AdaptyRecipes" --ref master \
    -f run_demo_builds=true \
    -f run_sdk_tests=false \
    -f matrix_override_json='[{"runner":"macos-15","xcode":"26.2","informational":false}]'
  ```

- Run tests only:
  ```bash
  gh workflow run "CI AdaptyRecipes" --ref master \
    -f run_demo_builds=false \
    -f run_sdk_tests=true
  ```

- Run tests with overridden ignored test errors:
  ```bash
  gh workflow run "CI AdaptyRecipes" --ref master \
    -f run_demo_builds=false \
    -f run_sdk_tests=true \
    -f ignored_test_errors_override_json='[{"message":"extra argument '\''profileId'\'' in call","file":"Tests/Placements/FallbackTests.swift","line":67}]'
  ```

Note: `ignored_test_errors_override_json` affects only `swift test` validation. Demo builds do not use ignored errors.

## Rule for Ignored Test Errors

Demo build jobs do not use ignored errors. In CI, `AppConstants.swift` is patched with dummy values before `xcodebuild`, and demo build must succeed without allowlisted failures.

Each ignored rule can be:

- exact message string
- object with `message` and optional `file`, `line`

Matching rules:

- `message` is matched exactly
- `file` matches exact path or suffix path
- `line` matches exact line number
- `line` is allowed only together with `file`
- secondary compiler summary lines (for example `emit-module/compile/frontend command failed ...`) are ignored when file/line diagnostics are present in the same log

An empty array `[]` is allowed and means "ignore nothing".

Regex and partial-message matching are not used.
