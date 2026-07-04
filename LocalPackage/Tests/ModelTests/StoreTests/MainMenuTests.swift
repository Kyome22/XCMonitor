import AllocatedUnfairLock
import AppKit
import Foundation
import Testing
import XCHook

@testable import DataSource
@testable import Model

struct MainMenuTests {
    private func event(
        project: String = "Sample",
        path: String = "/tmp/Sample.xcodeproj",
        status: XCHookStatus,
        timestamp: Double
    ) -> XCHookEvent {
        XCHookEvent(project: project, path: path, status: status, timestamp: timestamp)
    }

    @MainActor @Test
    func send_xchookEventReceived_updates_currentEvent_and_histories() async {
        let sut = MainMenu(.testDependencies())
        await sut.send(.xchookEventReceived(event(status: .buildStart, timestamp: 1)))
        await sut.send(.xchookEventReceived(event(status: .buildSucceeds, timestamp: 3)))
        #expect(sut.currentEvent.status == .buildSucceeds)
        #expect(sut.eventHistories == [
            EventHistory(
                project: "Sample",
                eventType: .buildSucceeded,
                elapsedTime: 2,
                projectURL: URL(fileURLWithPath: "/tmp/Sample.xcodeproj")
            ),
        ])
    }

    @MainActor @Test
    func send_xchookEventReceived_older_timestamp_keeps_currentEvent() async {
        let sut = MainMenu(
            .testDependencies(),
            currentEvent: event(status: .buildStart, timestamp: 10)
        )
        await sut.send(.xchookEventReceived(event(status: .buildSucceeds, timestamp: 5)))
        #expect(sut.currentEvent.status == .buildStart)
    }

    @MainActor @Test
    func send_xchookEventReceived_caps_histories_at_25() async {
        let sut = MainMenu(.testDependencies())
        for index in 0 ..< 26 {
            let timestamp = Double(2 * index)
            await sut.send(.xchookEventReceived(event(status: .buildStart, timestamp: timestamp)))
            await sut.send(.xchookEventReceived(event(status: .buildSucceeds, timestamp: timestamp + 1)))
        }
        #expect(sut.eventHistories.count == 25)
    }

    @MainActor @Test
    func send_applicationTerminated_xcode_resets_currentEvent_to_standby() async {
        let sut = MainMenu(
            .testDependencies(),
            currentEvent: event(status: .buildSucceeds, timestamp: 10)
        )
        await sut.send(.applicationTerminated("com.apple.dt.Xcode"))
        #expect(sut.currentEvent == .standby)
    }

    @MainActor @Test
    func send_applicationTerminated_other_application_keeps_currentEvent() async {
        let currentEvent = event(status: .buildSucceeds, timestamp: 10)
        let sut = MainMenu(.testDependencies(), currentEvent: currentEvent)
        await sut.send(.applicationTerminated("com.example.other"))
        #expect(sut.currentEvent == currentEvent)
    }

    @MainActor @Test
    func send_openProjectButtonTapped_empty_path_does_nothing() async {
        let alertCallStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(
            .testDependencies(
                nsAlertClient: testDependency(of: NSAlertClient.self) {
                    $0.runModal = { _ in
                        alertCallStack.withLock { $0.append("runModal") }
                        return .alertFirstButtonReturn
                    }
                }
            ),
            currentEvent: .standby
        )
        await sut.send(.openProjectButtonTapped)
        #expect(alertCallStack.withLock(\.self).isEmpty)
    }

    @MainActor @Test
    func send_openProjectButtonTapped_missing_file_shows_alert() async {
        let alertCallStack = AllocatedUnfairLock<[String]>(initialState: [])
        let openCallStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(
            .testDependencies(
                fileManagerClient: testDependency(of: FileManagerClient.self) {
                    $0.fileExists = { _ in false }
                },
                nsAlertClient: testDependency(of: NSAlertClient.self) {
                    $0.runModal = { alert in
                        alertCallStack.withLock { $0.append(alert.messageText) }
                        return .alertFirstButtonReturn
                    }
                },
                nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                    $0.open = { urls, _ in
                        openCallStack.withLock { $0.append(urls.map(\.path).joined()) }
                    }
                }
            ),
            currentEvent: event(status: .buildSucceeds, timestamp: 1)
        )
        await sut.send(.openProjectButtonTapped)
        #expect(alertCallStack.withLock(\.self).count == 1)
        #expect(openCallStack.withLock(\.self).isEmpty)
    }

    @MainActor @Test
    func send_openProjectButtonTapped_opens_project_in_xcode() async {
        let openCallStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(
            .testDependencies(
                fileManagerClient: testDependency(of: FileManagerClient.self) {
                    $0.fileExists = { _ in true }
                },
                nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                    $0.urlForApplication = { _ in URL(fileURLWithPath: "/Applications/Xcode.app") }
                    $0.open = { urls, applicationURL in
                        let entry = "open: \(urls.map(\.path).joined()) with: \(applicationURL.path)"
                        openCallStack.withLock { $0.append(entry) }
                    }
                }
            ),
            currentEvent: event(status: .buildSucceeds, timestamp: 1)
        )
        await sut.send(.openProjectButtonTapped)
        #expect(openCallStack.withLock(\.self) == ["open: /tmp/Sample.xcodeproj with: /Applications/Xcode.app"])
    }

    @MainActor @Test
    func send_historyButtonTapped_opens_history_project() async {
        let openCallStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(.testDependencies(
            fileManagerClient: testDependency(of: FileManagerClient.self) {
                $0.fileExists = { _ in true }
            },
            nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                $0.urlForApplication = { _ in URL(fileURLWithPath: "/Applications/Xcode.app") }
                $0.open = { urls, _ in
                    openCallStack.withLock { $0.append(urls.map(\.path).joined()) }
                }
            }
        ))
        let eventHistory = EventHistory(
            project: "Sample",
            eventType: .buildSucceeded,
            elapsedTime: 1,
            projectURL: URL(fileURLWithPath: "/tmp/Sample.xcodeproj")
        )
        await sut.send(.historyButtonTapped(eventHistory))
        #expect(openCallStack.withLock(\.self) == ["/tmp/Sample.xcodeproj"])
    }

    @MainActor @Test
    func send_task_observes_xchook_events() async {
        let (stream, continuation) = AsyncStream.makeStream(of: XCHookEvent.self)
        let sut = MainMenu(.testDependencies(
            xchookReceiverClient: testDependency(of: XCHookReceiverClient.self) {
                $0.events = { stream }
            }
        ))
        await sut.send(.task("MainMenuTests"))
        continuation.yield(event(status: .buildStart, timestamp: 1))
        await waitUntil { sut.currentEvent.status == .buildStart }
        #expect(sut.currentEvent.status == .buildStart)
        await sut.send(.onDisappear)
    }

    @MainActor @Test
    func send_task_observes_xcode_termination() async {
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)
        let sut = MainMenu(
            .testDependencies(
                nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                    $0.terminatedApplications = { stream }
                }
            ),
            currentEvent: event(status: .buildSucceeds, timestamp: 10)
        )
        await sut.send(.task("MainMenuTests"))
        continuation.yield("com.apple.dt.Xcode")
        await waitUntil { sut.currentEvent == .standby }
        #expect(sut.currentEvent == .standby)
        await sut.send(.onDisappear)
    }

    @MainActor @Test
    func send_aboutButtonTapped_activates_and_orders_front_about_panel() async {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { _ in
                    callStack.withLock { $0.append("activate") }
                }
                $0.orderFrontStandardAboutPanel = { _ in
                    callStack.withLock { $0.append("orderFrontStandardAboutPanel") }
                }
            }
        ))
        await sut.send(.aboutButtonTapped)
        #expect(callStack.withLock(\.self) == ["activate", "orderFrontStandardAboutPanel"])
    }

    @MainActor @Test
    func send_quitButtonTapped_terminates_app() async {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = MainMenu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.terminate = { _ in
                    callStack.withLock { $0.append("terminate") }
                }
            }
        ))
        await sut.send(.quitButtonTapped)
        #expect(callStack.withLock(\.self) == ["terminate"])
    }
}
