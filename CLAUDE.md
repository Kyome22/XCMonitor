# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

XCMonitor is a macOS menu bar app that monitors the progress of building and testing in Xcode. Target: macOS 15.0+, Swift 6.2 (with `ExistentialAny` upcoming feature enabled).

## Build & Test

The app shell lives in `XCMonitor.xcodeproj` and embeds the local Swift Package `LocalPackage/`, which contains essentially all source code. The `xcode` MCP tools (`mcp__xcode__BuildProject`, `mcp__xcode__RunAllTests`, etc.) are the preferred way to build and run tests — fall back to `xcodebuild` only when MCP is unavailable.

Tests live only in the SPM package (`DataSourceTests`, `ModelTests`) and use Swift Testing (`@Test`, `#expect`). Run via the `LocalPackage-Package` scheme on `platform=macOS,arch=arm64`. There are no UI tests and no linter configured.

## Architecture (LUCA)

The codebase follows the [LUCA architecture](https://github.com/Kyome22/LUCA) — three SPM library targets with strict layering:

- **`DataSource`** — leaf layer. Holds `Entities` (plain values: `AppState`, `AsyncStreamBundle`, etc.), `Dependencies` (thin `Sendable` wrappers around system APIs), and `Repositories` (composed of dependencies). Every dependency conforms to `DependencyClient` and exposes `liveValue` + `testValue` so tests can inject overrides via `testDependency(of:injection:)`.
- **`Model`** — depends on `DataSource`. Holds `Services` (long-lived workers wired in `AppDelegate`) and `Stores` (`@MainActor @Observable` view-models conforming to `Composable`). Also exposes `AppDependencies`, the bag of all dependency clients passed everywhere, plus the `AppDelegate`.
- **`UserInterface`** — depends on `DataSource` + `Model`. Holds SwiftUI `Scenes` and `Views`. Localized strings and assets live in `UserInterface/Resources`.

Never invert these dependencies (UI must not be imported by Model; Model must not be imported by DataSource).

### Stores and the Composable pattern

Stores implement `Composable`: they expose an `Action` enum and a `reduce(_ action:)` async function, with `send(_:)` calling `reduce` then forwarding to a parent-provided `action` closure. This is the only way views mutate state. When adding a new screen, create a `Store` in `Model/Stores/`, define its `Action`, and pair it with a SwiftUI `View` that calls `store.send(...)`.

### Cross-cutting state

Global app state flows through `AppStateClient` (an `AllocatedUnfairLock<AppState>`). Async streams in `AppState` are produced by services and consumed by stores via `for await` loops launched inside `reduce(.task)`.

`AppDependencies.shared` is the live singleton injected through the `\.appDependencies` SwiftUI environment value; tests construct one via `AppDependencies.testDependencies(...)`, overriding only the clients they care about.

## Code Conventions

`CODING_STYLE.md` defines the authoritative style rules (language, naming, comments, formatting, license headers) — read and follow it when editing code.
