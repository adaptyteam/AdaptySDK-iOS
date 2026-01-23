# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

See [CLAUDE.md](CLAUDE.md) for detailed documentation.

## Quick Reference

### Build & Test
```bash
swift build              # Build the project
swift test               # Run tests
```

### Version Management
```bash
./scripts/update_version.sh <version>  # Update version everywhere
```

### Code Style
- SwiftFormat configured via `.swiftformat`
- 4-space indentation, LF line breaks

## Architecture

- **Swift 6.0** with strict concurrency
- **@AdaptyActor** custom global actor for thread-safe SDK state
- **Dual StoreKit**: SK1 (iOS <15) and SK2 (iOS 15+) automatic selection

### Modules
| Module | Path | Purpose |
|--------|------|---------|
| `Adapty` | `Sources/` | Core SDK |
| `AdaptyLogger` | `Sources.Logger/` | Logging |
| `AdaptyUIBuilder` | `Sources.UIBuilder/` | UI schema |
| `AdaptyUI` | `Sources.AdaptyUI/` | Paywall UI |
| `AdaptyPlugin` | `Sources.AdaptyPlugin/` | Cross-platform bridge |
