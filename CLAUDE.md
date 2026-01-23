# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See also: [AGENTS.md](AGENTS.md) for other AI coding agents.

## Project Overview

Adapty iOS SDK - an open-source framework for implementing in-app subscriptions. Supports iOS 13+, macOS 11+, and visionOS 1+.

## Build System

The project uses both **Swift Package Manager** (primary) and **CocoaPods** for distribution.

### Building

```bash
swift package resolve
swift build
```

### Running Tests

```bash
swift test
```

Tests use Apple's `Testing` framework (`@Test` macro). Test fixtures are in `Tests/Placements/`.

### Code Formatting

SwiftFormat is configured via `.swiftformat`. Key settings:
- 4-space indentation
- LF line breaks
- Import grouping: testable-last

### Version Management

```bash
./scripts/update_version.sh <version>  # e.g., 3.15.0 or 3.15.0-SNAPSHOT
```

This updates version across `Sources/Versions.swift`, `cross_platform.yaml`, and all podspec files.

### Publishing to CocoaPods

```bash
./scripts/publish_podspecs.sh [--skip-lint] [--skip-tests] [--max-retries N]
```

Publishes in dependency order: Adapty → AdaptyUI → AdaptyPlugin.

## Architecture

### Module Structure

| Module | Path | Purpose |
|--------|------|---------|
| `AdaptyLogger` | `Sources.Logger/` | Logging with OSLog integration |
| `AdaptyUIBuilder` | `Sources.UIBuilder/` | UI schema parsing and configuration |
| `Adapty` | `Sources/` | Core SDK - purchases, profiles, backend |
| `AdaptyUI` | `Sources.AdaptyUI/` | Paywall and onboarding UI components |
| `AdaptyPlugin` | `Sources.AdaptyPlugin/` | Cross-platform bridge layer |
| `Adapty_KidsMode` | `Sources.KidsMode/` | COPPA-compliant variant |
| `AdaptyDeveloperTools` | `Sources.DeveloperTools/` | Developer utilities |

### Key Architectural Patterns

- **@AdaptyActor**: Custom global actor for thread-safe SDK state management (see `AdaptyActor.swift`)
- **Dual StoreKit Support**: SK1 for iOS <15, SK2 for iOS 15+ (automatic selection in `Adapty.swift`)
- **Backend Abstraction**: Pluggable HTTP executors (`Main+Backend/`, `Fallback+Backend/`, `State+Backend/`)
- **Event Collection**: Analytics system in `Sources/Events/`

### Core SDK Structure (`Sources/`)

```
Sources/
├── Adapty.swift              # Main singleton class
├── Adapty+Activate.swift     # SDK initialization
├── AdaptyConfiguration.swift # Configuration options
├── Backend/                  # HTTP layer with multiple executors
├── StoreKit/                 # SK1QueueManager, SK2TransactionManager
├── Profile/                  # User profile and subscription state
├── Placements/               # Paywall and placement logic
├── Events/                   # Event tracking
└── Storage/                  # Local persistence
```

## Swift Concurrency

The codebase uses Swift 6.0 with strict concurrency. The `@AdaptyActor` global actor isolates SDK state. Public APIs support both async/await and completion handlers.
