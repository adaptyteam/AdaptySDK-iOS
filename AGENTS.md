# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

Adapty iOS SDK for - an open-source framework.
Supports iOS 15+, macOS 12+, and visionOS 2+.
The codebase uses Swift 6.2 with strict concurrency.
Public APIs of SDK support both async/await and completion handlers.

## Building SDK

```bash
swift package resolve
swift build
```

## Running Tests of SDK

```bash
swift test
```

## SDK Version Management
For update version read scripts/README.md 

## Publishing to CocoaPods

Spec repo (4.x, the only channel after the trunk freeze on 2026-12-02): pushing a release tag runs the
**Publish CocoaPods specs** workflow, which needs an approval in the `cocoapods-specs` environment.
Manual and snapshot use: `scripts/cocoapods-specs/publish.sh` (see scripts/README.md).

Trunk (until 2026-12-02):

```bash
./scripts/publish_podspecs.sh [--skip-lint] [--skip-tests] [--max-retries N]
```
Publishes in dependency order: AdaptyLogger → AdaptyCSimdjson → AdaptyCodable → AdaptyUIBuilder → Adapty → AdaptyUI → AdaptyPlugin. Details in scripts/README.md.

## Sources Structure
| Module                 | Path                      | Purpose                                    |
| ---------------------- | ------------------------- | ------------------------------------------ |
| `Adapty`               | `Sources/`                | Adapty SDK                                 |
| `AdaptyLogger`         | `Sources.Logger/`         | Library for Logging                        |
| `AdaptyUIBuilder`      | `Sources.UIBuilder/`      | Library for build UI from JSON config.     |
| `AdaptyUI`             | `Sources.AdaptyUI/`       | Adapty UI SDK for Onbording and Paywall UI |
| `AdaptyPlugin`         | `Sources.AdaptyPlugin/`   | Library for cross-platform bridge          |
| `AdaptyDeveloperTools` | `Sources.DeveloperTools/` | Library for Developer utilities  bridge    |

Kids Mode (COPPA / App Store Kids Category) is a package **trait** `KidsMode`, not a
separate module. Enable it on the `Adapty` / `AdaptyUI` / `AdaptyPlugin` dependency
(`traits: ["KidsMode"]`) to activate the `#if KidsMode` guards that compile out IDFA /
AdSupport.