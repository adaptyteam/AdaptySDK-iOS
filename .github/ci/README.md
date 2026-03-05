# CI Configuration for SDK Validation

This folder contains the source-of-truth config for the manual `SDK Validation` workflow.

Main files:

- Workflow: `.github/workflows/sdk-validation.yml`
- Config: `.github/ci/ci-run-config.json`
- Config preparation: `scripts/ci/sdk_validation/prepare-config.js`
- Shared shell logging: `scripts/ci/sdk_validation/lib/logging.sh`
- Build/test helpers: `scripts/ci/sdk_validation/`

The workflow is manual-only (`workflow_dispatch`). There are no automatic triggers for pull requests or pushes.

## Workflow Shape

There is one workflow, `SDK Validation`, with four user-facing validation flows controlled by workflow inputs:

- `build_sdk_targets`
- `build_test_app`
- `run_tests`
- `lint_pods`

Internally, the workflow also has one technical job, `Prepare CI config`, that:

- validates workflow input defaults against `.github/ci/ci-run-config.json`
- parses boolean and JSON overrides
- validates matrix structure
- derives the effective matrices used by downstream jobs

Default manual profile:

- `build_sdk_targets = true`
- `build_test_app = true`
- `run_tests = true`
- `lint_pods = false`

Concurrency behavior:

- manual runs are grouped by `workflow + ref`
- starting a new `SDK Validation` run on the same branch cancels the previous in-progress run on that branch

## Validation Flows

### `build_sdk_targets`

What it does:

- runs `build_sdk_matrix` across `build_matrix`
- for each matrix entry:
  - resolves SwiftPM dependencies inside the configured scratch path
  - discovers library products from `Package.swift`
  - builds each SwiftPM library target
- on the primary `sdk_tests.runner + sdk_tests.xcode` entry, also builds the iOS package scheme `Adapty-Package`
- runs a separate `macos_sdk_build` job on `sdk_tests.runner + sdk_tests.xcode`

Scripts involved:

- `scripts/ci/sdk_validation/build-spm-library-targets.sh`
- `scripts/ci/sdk_validation/list-library-targets.js`
- `scripts/ci/sdk_validation/lib/logging.sh`

Inputs that affect it:

- `build_sdk_targets`
- `build_matrix_override_json`

Behavior:

- default config is blocking
- `build_matrix` entries may use `informational: true`; those entries run with `continue-on-error`
- the primary `sdk_tests.runner + sdk_tests.xcode` entry must exist in `build_matrix`
- the primary build entry must have `informational: false`

Artifacts:

- `swift-build-products-log-<runner>-xcode-<xcode>`
- `swift-build-macos-log-xcode-<xcode>`

### `build_test_app`

What it does:

- builds `Examples/AdaptyRecipes-SwiftUI/AdaptyRecipes-SwiftUI.xcodeproj`
- writes CI-specific demo constants before the build
- uploads `xcodebuild.log` even when `xcodebuild` returns non-zero

Scripts involved:

- `scripts/ci/sdk_validation/write-demo-constants.sh`
- `scripts/ci/sdk_validation/build-demo-app.sh`
- `scripts/ci/sdk_validation/lib/logging.sh`

Inputs that affect it:

- `build_test_app`
- `build_matrix_override_json`

Behavior:

- runs only on the single primary entry derived from `build_matrix`
- the helper writes `exit_code` to `GITHUB_OUTPUT`
- the workflow uploads the log first, then fails in a separate step if `exit_code != 0`
- effectively blocking, because the derived primary entry must have `informational: false`

Artifact:

- `demo-build-log-<runner>-xcode-<xcode>`

### `run_tests`

What it does:

- runs `sdk_tests` across `sdk_tests_matrix`
- for each matrix entry:
  - resolves SwiftPM dependencies
  - runs `swift test`
- uploads `swift-test.log` even when `swift test` returns non-zero

Scripts involved:

- `scripts/ci/sdk_validation/run-sdk-tests.sh`
- `scripts/ci/sdk_validation/lib/logging.sh`

Inputs that affect it:

- `run_tests`
- `sdk_tests_matrix_override_json`

Behavior:

- default config is blocking, because the default matrix contains one primary entry with `informational: false`
- override entries may use `informational: true`; those entries run with `continue-on-error`
- `sdk_tests_matrix_override_json` does not have to include the primary `sdk_tests` entry
- there is no whitelist mechanism
- the helper writes `exit_code` to `GITHUB_OUTPUT`
- the workflow uploads the log first, then fails in a separate step if `exit_code != 0`

Artifact:

- `sdk-tests-log-<runner>-xcode-<xcode>`

### `lint_pods`

What it does:

- runs `pod lib lint` for:
  - `Adapty.podspec`
  - `AdaptyUI.podspec`
  - `AdaptyPlugin.podspec`

Scripts involved:

- `scripts/ci/sdk_validation/run-pod-lib-lint.sh`
- `scripts/ci/sdk_validation/lib/logging.sh`

Inputs that affect it:

- `lint_pods`

Behavior:

- blocking
- runs only on `sdk_tests.runner + sdk_tests.xcode`
- there is no whitelist mechanism

Artifact:

- `pod-lib-lint-log-xcode-<xcode>`

## Logging Model

All artifact-producing shell helpers use the same logging contract from `scripts/ci/sdk_validation/lib/logging.sh`.

After log initialization:

- stdout and stderr are mirrored to both live Actions output and the log file
- early failures are written into the artifact log
- helpers must not use extra `tee -a` logging on top of the shared logger

Current artifact-owning helpers:

- `build-spm-library-targets.sh`
- `build-demo-app.sh`
- `run-sdk-tests.sh`
- `run-pod-lib-lint.sh`

Special cases:

- `build-demo-app.sh` and `run-sdk-tests.sh` intentionally do not fail their step on command non-zero
- instead, they store `exit_code` in `GITHUB_OUTPUT`, so the workflow can upload the log artifact before failing

## Manual Run Inputs

### Boolean flags

- `build_sdk_targets`: enable SDK builds
- `build_test_app`: enable demo app build
- `run_tests`: enable `swift test`
- `lint_pods`: enable CocoaPods lint

At least one of these flags must be `true`.

### JSON overrides

- `build_matrix_override_json`: override for SDK build matrix and primary build entry selection
- `sdk_tests_matrix_override_json`: override for `swift test` matrix

Accepted formats:

- JSON array of matrix entries
- JSON object with `include: [...]`

Matrix entry shape:

```json
{
  "runner": "macos-15",
  "xcode": "26.2",
  "informational": false
}
```

Rules:

- `runner + xcode` pairs must be unique
- `informational: true` means the matrix entry is advisory and uses `continue-on-error`
- if `build_sdk_targets=true` or `build_test_app=true`, `build_matrix` must include the primary `sdk_tests` entry with `informational: false`
- `sdk_tests_matrix_override_json` may omit the primary `sdk_tests` entry entirely for custom test-only runs

## Validation Rules

- `Prepare CI config` fails if all four boolean flags are `false`
- workflow input defaults in `workflow_dispatch` must stay in sync with `.github/ci/ci-run-config.json`
- matrix override JSON must be a non-empty array or an object with `include[]`
- matrix entries must be unique by `runner + xcode`
- `build_test_app` always derives a single-entry matrix from the primary build entry

## Xcode Selection Behavior

- matrix jobs use `setup-xcode` for the requested version
- if a matrix entry is `informational: true` and Xcode is unavailable, that entry is skipped with a warning
- if a matrix entry is `informational: false` and Xcode is unavailable, that entry fails
- `SDK macOS build` and `CocoaPods lint` are single-Xcode jobs and fail if the configured Xcode is unavailable
- iOS-specific steps (`Adapty-Package` and `AdaptyRecipes-SwiftUI`) run only on the primary `sdk_tests.runner + sdk_tests.xcode`

## Manual Run Guide

### GitHub UI

1. Open `Actions`.
2. Select `SDK Validation`.
3. Click `Run workflow`.
4. Choose the branch in `Use workflow from`.
5. Leave the default profile or override flags/JSON inputs.
6. Click `Run workflow`.

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

Run only demo app build:

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

Artifacts produced by the workflow:

- `swift-build-products-log-...`
- `demo-build-log-...`
- `swift-build-macos-log-...`
- `pod-lib-lint-log-...`
- `sdk-tests-log-...`
