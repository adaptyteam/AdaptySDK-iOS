# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

Adapty iOS SDK for - an open-source framework.
Supports iOS 13+, macOS 11+, and visionOS 1+.
The codebase uses Swift 6.0 with strict concurrency.
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

```bash
./scripts/publish_podspecs.sh [--skip-lint] [--skip-tests] [--max-retries N]
```
Publishes in dependency order: Adapty → AdaptyUI → AdaptyPlugin.

## Sources Structure
| Module                 | Path                      | Purpose                                    |
| ---------------------- | ------------------------- | ------------------------------------------ |
| `Adapty`               | `Sources/`                | Adapty SDK                                 |
| `AdaptyLogger`         | `Sources.Logger/`         | Library for Logging                        |
| `AdaptyUIBuilder`      | `Sources.UIBuilder/`      | Library for build UI from JSON config.     |
| `AdaptyUI`             | `Sources.AdaptyUI/`       | Adapty UI SDK for Onbording and Paywall UI |
| `AdaptyPlugin`         | `Sources.AdaptyPlugin/`   | Library for cross-platform bridge          |
| `AdaptyDeveloperTools` | `Sources.DeveloperTools/` | Library for Developer utilities  bridge    |
| `Adapty_KidsMode`      | `Sources.KidsMode/`       | COPPA-compliant variant of Adapty SDK      |