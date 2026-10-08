# Scripts

This directory contains utility scripts for the Adapty iOS SDK project.

## Version Management

### `update_version.sh`

**Purpose**: Updates the Adapty iOS SDK version across all necessary files in the project.

**Usage**:
```bash
# From project root directory
./scripts/update_version.sh <new_version>

# Examples
./scripts/update_version.sh 3.12.0
./scripts/update_version.sh 3.12.0-SNAPSHOT
```

**What it does**:
- Updates version in `Sources/Versions.swift` (main SDK version constant)
- Updates version in `Sources.AdaptyPlugin/cross_platform.yaml` (cross-platform schema version)
- Updates version in all podspec files (CocoaPods specification)
- Validates version format
- Verifies all changes were applied correctly
- Shows summary of all updated files

**Version format**: `x.y.z` or `x.y.z-SUFFIX` (e.g., `3.12.0`, `3.12.0-SNAPSHOT`)

**Note**: This script should be used whenever you need to change the SDK version. Do not manually edit version numbers in individual files.

## Publishing to CocoaPods

### `publish_podspecs.sh`

**Purpose**: Publishes all Adapty iOS SDK podspecs to CocoaPods trunk in dependency order, with retries.

**Usage**:
```bash
# From project root directory
./scripts/publish_podspecs.sh [OPTIONS]

# Examples
./scripts/publish_podspecs.sh
./scripts/publish_podspecs.sh --skip-lint
./scripts/publish_podspecs.sh --skip-tests
./scripts/publish_podspecs.sh --max-retries 10
```

**Options**:
- `--skip-lint`: Skip `pod lib lint` before publishing (faster, but less safe)
- `--skip-tests`: Skip building and running tests during validation for all podspecs
- `--max-retries N`: Maximum number of retries for each podspec (default: 5)
- `--help`: Show help message

**What it does**:
1. Publishes podspecs in dependency order: `AdaptyLogger`, `AdaptyCSimdjson`, `AdaptyCodable`, `AdaptyUIBuilder`, `Adapty`, `AdaptyUI`, `AdaptyPlugin`.
2. For each podspec:
   - Runs `pod repo update` to pick up the pods published before it
   - Runs `pod lib lint` (unless `--skip-lint` is used); tests are skipped for podspecs that have dependencies
   - Publishes with `pod trunk push --synchronous`, which waits for the dependencies pushed just before to become available
   - Retries on failure up to `--max-retries` times
3. Stops if any podspec fails to publish.

**Prerequisites**:
- CocoaPods must be installed (`gem install cocoapods`)
- You must be registered with CocoaPods trunk (`pod trunk register`, check with `pod trunk me`)

**Note**: Run `update_version.sh` first, so that every podspec carries the version being released; the podspecs point at the git tag of that version.

## Publishing to AdaptySDK-CocoaPods-Specs

CocoaPods trunk becomes read-only on 2026-12-02; the 4.x pods are published to
[adaptyteam/AdaptySDK-CocoaPods-Specs](https://github.com/adaptyteam/AdaptySDK-CocoaPods-Specs).

### Release (CI)

1. Push the release tag (`x.y.z`, equal to the podspec version). The tag must contain all seven podspecs.
2. The **Publish CocoaPods specs** workflow runs `stage`: it lints the pods that are not published yet
   (about 20–40 minutes). Nothing is pushed in this job. Its summary shows the version, ref, SHA and pods.
3. The `publish` job waits for approval in the `cocoapods-specs` environment. A reviewer other than the
   person who started the run checks the ref and SHA in the run header against the summary and approves.
4. `publish` verifies the staged specs and pushes them to the spec repo in one commit.
5. Check the result in the spec repo directly:
   `git ls-remote https://github.com/adaptyteam/AdaptySDK-CocoaPods-Specs.git refs/heads/main` shows the
   new head, and `Specs/<Pod>/x.y.z` is there on GitHub. Only if the spec repo is added locally:
   `pod repo update && pod spec cat AdaptyPlugin --version=x.y.z`.
6. Tell the wrapper maintainers (React Native, Capacitor, Flutter, Unity) to bump their pod version.

A version that is already published from the same source is skipped, so re-running is safe. A version
published from another source is refused: published versions are immutable, publish a new version.

### Snapshot (CI, from a branch)

Run the workflow manually ("Run workflow") on `dev`, `master`, `release/*` or `hotfix/*` (`master` works
only once it contains the podspecs). The source is pinned to the branch head commit. A manual run from any
other branch only runs `stage`: it is a dry run, the environment refuses `publish`. **Commit a version that
will never be a release first** (for example `./scripts/update_version.sh 4.3.0-SNAPSHOT.1`): a snapshot
published as `4.3.0` blocks the real `4.3.0` release forever.

### Failures

| What happened | What to do |
|---|---|
| A pod fails lint in `stage` | Fix it, then a new tag (or a new snapshot version) |
| `stage` says the version is published from another source | Publish a new version |
| `publish` failed (network, token) | "Re-run failed jobs" within 30 days; another reviewer approves |
| `publish` was cancelled or stays pending (another run took the concurrency slot) | Reject stale waiting runs, then re-run the cancelled run's failed jobs within 30 days |
| `publish` is red after pushing (`main does not match the pushed commit`) | Another push landed right after ours; re-run — it reports Nothing to publish if the specs are in |
| Bug in the workflow or script on a release tag | Tags cannot be moved; an org admin publishes manually with the fixed script |

### Manual use

```bash
# Dry run for anyone: lint into a directory, push nothing
scripts/cocoapods-specs/publish.sh stage --ref 4.3.0 --out /tmp/staged
scripts/cocoapods-specs/publish.sh verify --from /tmp/staged

# Break-glass for org admins (the spec repo's main accepts pushes only from the CI app and admins)
scripts/cocoapods-specs/publish.sh --ref 4.3.0
```

Tests: `scripts/cocoapods-specs/test/run.sh`.
