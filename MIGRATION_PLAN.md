# MIGRATION_PLAN — XCMonitor → RunCatNeo-style LUCA

## Phase Status
- [x] Phase 0 — Inventory (user approved)
- [x] Phase 1 — Scaffold
- [x] Phase 2 — DataSource
- [x] Phase 3 — Model
- [ ] Phase 4 — UserInterface
- [ ] Phase 5 — Cutover (user smoke test passed)
- [ ] Phase 6 — Cleanup

## App facts
| Item | Value |
|---|---|
| Bundle ID | com.kyome.XCMonitor |
| Display name | XCMonitor |
| Deployment target | 15.0 (keep) |
| App type | menu-bar only (LSUIElement = YES) + Settings window |
| Sandbox & capabilities | sandbox OFF (entitlements file empty dict), hardened runtime ON |
| Entitlements file | XCMonitor/XCMonitor.entitlements (empty dict — carry verbatim) |
| IAP | none |
| License / header type | MIT — short MIT header (NewCanvas precedent), user confirmed |
| Error prefix | XCM (user confirmed) |
| Localizations | en (source), ja / knownRegions: en, Base, ja |
| External packages | XCHook 1.0.0 exact — keep; + standard AllocatedUnfairLock, swift-async-algorithms, swift-log |
| Current versions | CURRENT_PROJECT_VERSION = 1.4.0 / MARKETING_VERSION = 1.4 |
| App category (LSApplicationCategoryType) | public.app-category.developer-tools |

Old targets: XCMonitor (app) + XCMonitorLauncher (SMLoginItem helper, com.kyome.XCMonitorLauncher).
**XCMonitorLauncher is deleted entirely** — launch-at-login is reimplemented with
`SMAppService.mainApp` via `SMAppServiceClient` + `LaunchAtLoginRepository`, same shape as ScreenNote
(user decision).

## Features & screens (smoke-test checklist for Phase 5)
- [ ] Menu bar icon appears at launch (standby), no Dock icon.
- [ ] Building/testing in Xcode flips the icon through build-start / succeeds / fails (and testing variants), respecting light/dark menu bar.
- [ ] "Show “X” Project on Xcode" item shows current project and opens it in Xcode; disabled ("No Project") when none.
- [ ] Event History submenu lists paired results ("Project: Build Succeeded (12.345 sec)" with result icon, newest first, max 25); shows disabled "Empty" when none.
- [ ] Clicking a history entry whose project file no longer exists shows the "could not open" alert.
- [ ] Quitting Xcode resets the icon and project item to standby.
- [ ] Settings > General: XCHook toggle ON shows overwrite confirmation → Enable installs scripts; if Xcode is running, offers restart (Restart Now relaunches Xcode). Toggle OFF uninstalls, same restart offer.
- [ ] XCHook toggle with no Xcode.plist shows "Xcode.plist Not Found" alert and reverts.
- [ ] Install/uninstall failure shows "Operation Failed" alert and reverts the toggle.
- [ ] Launch-at-login toggle registers/unregisters the app in System Settings > Login Items (SMAppService.mainApp).
- [ ] About XCMonitor opens the standard about panel.
- [ ] Quit XCMonitor terminates the app.
- [ ] Old settings continuity: n/a (the old app persisted nothing in UserDefaults).

## State inventory (compatibility contract)
| UserDefaults key (literal) | Type | Default | Read/written by (old) | New home |
|---|---|---|---|---|
| (none — the old app has zero UserDefaults/@AppStorage usage) | | | | |

→ Per PLAYBOOK Phase 2 rule: skip `UserDefaultsClient`, `UserDefaultsRepository`, key constants, and the key-pinning test.

Other persisted state:
- XCHook script installation state lives in the filesystem / Xcode's own preferences (owned by the XCHook package, not us).
- Launch-at-login: old = launchd job "com.kyome.XCMonitorLauncher" via `SMLoginItemSetEnabled` + embedded XCMonitorLauncher.app; new = `SMAppService.mainApp` status. See Tricky items.

## System-API touchpoints → clients
| API | Old call sites | New client | Copy from sibling? |
|---|---|---|---|
| `XCHook()` init (failable), `isInstalled()`, `install()`, `uninstall()` | GeneralSettingsViewModel | `XCHookClient` (`make: () -> XCHook?`, `isInstalled: (XCHook) -> Bool`, `install/uninstall: (XCHook) throws -> Void` — SpiceKey-style thin wrapper over a passed handle) | precedent: SpiceKeyClient shape (ScreenNote) |
| `XCHookReceiver.events` | MenuBarModel | `XCHookReceiverClient` (`events: () -> any AsyncSequence<XCHookEvent, Never> & Sendable`; testValue: empty stream) | new |
| `XcodeApplication.isRunning` / `.restart()` | GeneralSettingsViewModel | `XcodeApplicationClient` (`isRunning: () -> Bool`, `restart: () async -> Bool`) | new |
| `SMCopyAllJobDictionaries` / `SMLoginItemSetEnabled` | GeneralSettingsViewModel | **replaced** by `SMAppServiceClient` (`isEnabled/register/unregister`, SMAppService.mainApp) | copy from ScreenNote |
| `NSWorkspace.urlForApplication(withBundleIdentifier:)`, `open([URL], withApplicationAt:...)` | MenuBarModel | `NSWorkspaceClient` | trim from ScreenNote/RunCatNeo |
| `NSWorkspace.didTerminateApplicationNotification` | MenuBarModel | fold into `NSWorkspaceClient` as `terminatedApplications: () -> AsyncStream<String>` (bundle IDs, Notification→Sendable inside liveValue) | HandyPalette precedent |
| `FileManager.fileExists(atPath:)` | MenuBarModel (openXcodeProject guard) | `FileManagerClient` (`fileExists: (String) -> Bool`) | new (thin) |
| `NSAlert.runModal` (project not open) | MenuBarModel | `NSAlertClient` (menu-triggered, no window) — strings via Model-target resource catalog | QuickMIDI precedent |
| `NSApp.activate`, `orderFrontStandardAboutPanel` | AppDelegate.openAboutWindow | `NSAppClient` (`activate: (Bool)`, `orderFrontStandardAboutPanel: ([NSApplication.AboutPanelOptionKey: Any]?)`) | ScreenNote |
| `NSApp.sendAction(showPreferencesWindow:)` hack | AppDelegate.openPreferencesWindow | **dropped** — SwiftUI `SettingsLink` in MenuBarExtra content | n/a |
| `NSApp.setActivationPolicy(.accessory)` | AppDelegate | **dropped** — LSUIElement handles it | n/a |
| `NSApp.terminate` | MenuBar quit item | `NSAppClient.terminate: (Any?)` | ScreenNote |
| `NSStatusItem` / `NSMenu` / appearance KVO | MenuBar | **dropped** — native `MenuBarExtra` scene; dark/light images become asset appearance variants (Any + Dark) | ladder step 1 |

## Cross-layer streams (AppState.AsyncStreamBundle fields)
| Stream | T | Producer | Consumers |
|---|---|---|---|
| (none) | | | |

Only the `MainMenu` store consumes XCHook events and Xcode-termination notifications; both are
screen-local and subscribed directly from the clients in `reduce(.task)` (HandyPalette judgment:
streams only for state crossing scene/store boundaries). AppState keeps only `hasAlreadyBootstrap`:
the `EnvironmentInfo` cluster (`EnvironmentInfo`, `Bundle+Extension`, `ProcessInfo+Extension`) is
dropped — the about box is the standard `orderFrontStandardAboutPanel` and there is no
diagnostics UI, so it would have zero consumers (NewCanvas precedent). `UserDefaultsClient` is
likewise skipped (no persisted keys).

## File mapping (every old file)
| Old path | Action | New path / reason |
|---|---|---|
| XCMonitor/XCMonitorApp.swift | rewrite | shell `XCMonitor/XCMonitorApp.swift` (AppMain template; MenuBarScene + SettingsScene) |
| XCMonitor/Model/AppDelegate.swift | rewrite ✅ | `LocalPackage/Sources/Model/AppDelegate.swift` (template; about/preferences actions move to MainMenu store) |
| XCMonitor/Model/EventHistory.swift | split ✅ (DataSource+Model done, imageName pends Phase 4) | value core → `DataSource/Entities/EventHistory.swift` + `EventType`; pairing algorithm from MenuBarModel.addEvent joins it as pure logic; `imageName`/display name → `UserInterface/Extensions/EventType+Extension.swift` |
| XCMonitor/ViewModel/MenuBarModel.swift | rewrite ✅ | `Model/Stores/MainMenu.swift` (event list, current event, histories, open-project actions) |
| XCMonitor/ViewModel/GeneralSettingsViewModel.swift | rewrite ✅ | `Model/Stores/GeneralSettings.swift` + `Model/Services/XCHookService.swift` + `DataSource/Repositories/LaunchAtLoginRepository.swift` |
| XCMonitor/View/MenuBar.swift | rewrite | `UserInterface/Views/MainMenuView.swift` (+ label image logic) via `Scenes/MenuBarScene.swift` |
| XCMonitor/View/HistoryMenuItem.swift | drop | SwiftUI Button rows carry `EventHistory` directly |
| XCMonitor/View/Extensions.swift | drop | `.localized`/`isDark`/`state`/`isOn` all obsolete under xcstrings + asset variants + SwiftUI |
| XCMonitor/View/SettingsView.swift | port | `UserInterface/Views/SettingsView.swift` (TabView, General tab) + `Scenes/SettingsScene.swift` |
| XCMonitor/View/GeneralSettingsView.swift | rewrite | `UserInterface/Views/GeneralSettingsView.swift` (store-driven, alert cases) |
| XCMonitor/en.lproj/Localizable.strings, ja.lproj | convert | `UserInterface/Resources/Localizable.xcstrings` (+ trimmed Model-target catalog for the NSAlert strings, QuickMIDI precedent) |
| XCMonitor/Assets.xcassets AppIcon + AccentColor | move | shell `XCMonitor/Assets.xcassets` (icon stays in shell) |
| XCMonitor/Assets.xcassets MenuBar/* (7 status × light/dark) | merge | `UserInterface/Resources/Media.xcassets` — one imageset per status with Any/Dark appearance variants |
| XCMonitor/Assets.xcassets MenuItem/* (4 result icons) | move | `UserInterface/Resources/Media.xcassets` |
| XCMonitor/Assets.xcassets General.imageset | drop | unreferenced (tab uses systemImage "gear") |
| XCMonitor/Info.plist (LSUIElement) | replace | pbxproj `INFOPLIST_KEY_LSUIElement = YES` + minimal shell Info.plist |
| XCMonitor/XCMonitor.entitlements | carry verbatim | shell `XCMonitor/XCMonitor.entitlements` |
| XCMonitorLauncher/main.swift, AppDelegate.swift, Info.plist, entitlements | **drop (target deleted)** | replaced by SMAppService.mainApp launch-at-login |
| Resources/*.png, *.ai, *.psd, *.gif | keep as-is | README assets, untouched |

## Tricky items
### Menu bar UI (NSStatusItem + NSMenu + appearance KVO → MenuBarExtra)
Strategy: ladder step 1 — a native `MenuBarExtra` scene with menu-style content suffices (static
image label, plain menu items, one submenu). The scene owns the `MainMenu` store as `@State`
(label and content share it; the label view is always mounted so its `.task` starts event
observation at launch). Light/dark icon switching moves from manual KVO on
`effectiveAppearance` to asset-catalog appearance variants (Any + Dark per status imageset).
Menu-item enablement (`NSMenuItemValidation`) becomes `.disabled(store.currentEvent.path.isEmpty)`.
(precedent: ScreenNote MenuBarScene/MainMenu)

### Launch at login (SMLoginItemSetEnabled + helper app → SMAppService.mainApp)
Strategy: user decision — delete the XCMonitorLauncher target and copy ScreenNote's
`SMAppServiceClient` + `LaunchAtLoginRepository` (`switchStatus(_:) -> Result<Void, SwitchError>`
verifying post-switch status). The GeneralSettings store reverts the toggle on `.switchFailed`.
Upgrade note: an existing user's old launchd registration ("com.kyome.XCMonitorLauncher") points at
the embedded helper, which disappears with the new bundle — launchd then has nothing to launch, so
the stale registration is inert; no cleanup code is carried. (precedent: ScreenNote)

### Event pairing algorithm (MenuBarModel.addEvent)
Strategy: pure logic — sorted event list capped at 50, adjacent same-project start/finish pairs
folded into `EventHistory` values (max 25, newest first). Moves to DataSource as
`EventHistory.histories(from: [XCHookEvent])` (static pure function on the entity) so it is
unit-tested without any client. The store keeps only the list mutation + delegation.
(precedent: none — plain value logic)

### Project-not-open alert from a menu click (NSAlert.runModal)
Strategy: menu-bar apps have no window to anchor a SwiftUI alert when the menu has already closed,
so keep the modal NSAlert behind a thin `NSAlertClient`; the alert title/informative strings live in
a trimmed Model-target string catalog. (precedent: QuickMIDI NSAlertClient)

### XCHook confirmation / restart flow (GeneralSettings)
Strategy: port the four alert cases (`xcodePlistNotFound`, `xchookWarning` confirm,
`xcodeRestart` offer, `operationFailed`) as a store `alertType` + `showingAlert` state driven by
Action cases; install/uninstall/restart composition lives in `XCHookService` over `XCHookClient` +
`XcodeApplicationClient` so the confirm→install→offer-restart sequence is fully unit-tested.
(precedent: none direct; standard store+service split)

## Build settings extract
| Placeholder | Value |
|---|---|
| BUNDLE_ID | com.kyome.XCMonitor |
| DISPLAY_NAME | XCMonitor |
| MACOS_DEPLOYMENT_TARGET | 15.0 |
| BUILD_VERSION | 1.4.0 |
| MARKETING_VERSION | 1.4 |
| APP_CATEGORY | public.app-category.developer-tools |
| LS_UI_ELEMENT | YES |
| KNOWN_REGIONS | en, Base, ja |
| DEVELOPMENT_TEAM | VJ5N2X84K8 |
| Sandbox | ENABLE_APP_SANDBOX = NO (entitlements: empty dict — source of truth) |
| Hardened runtime | ENABLE_HARDENED_RUNTIME = YES |
| Copyright | © 2022 Takuto Nakamura |
