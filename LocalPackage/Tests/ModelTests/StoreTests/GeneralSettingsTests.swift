import AllocatedUnfairLock
import Testing

@testable import DataSource
@testable import Model

private enum TestError: Error {
    case operationFailed
}

struct GeneralSettingsTests {
    private func availableXCHookClient(
        installCallStack: AllocatedUnfairLock<[String]>? = nil,
        install: (@Sendable () throws -> Void)? = nil,
        uninstall: (@Sendable () throws -> Void)? = nil
    ) -> XCHookClient {
        testDependency(of: XCHookClient.self) {
            $0.isAvailable = { true }
            $0.install = {
                try install?()
                installCallStack?.withLock { $0.append("install") }
            }
            $0.uninstall = {
                try uninstall?()
                installCallStack?.withLock { $0.append("uninstall") }
            }
        }
    }

    @MainActor @Test
    func send_xchookToggleSwitched_same_value_does_nothing() async {
        let sut = GeneralSettings(.testDependencies(), xchookEnabled: false)
        await sut.send(.xchookToggleSwitched(false))
        #expect(sut.showingAlert == false)
    }

    @MainActor @Test
    func send_xchookToggleSwitched_true_without_xcode_plist_shows_plist_alert() async {
        let sut = GeneralSettings(.testDependencies(), xchookEnabled: false)
        await sut.send(.xchookToggleSwitched(true))
        #expect(sut.showingAlert)
        #expect(sut.alertType == .xcodePlistNotFound)
        #expect(sut.xchookEnabled == false)
    }

    @MainActor @Test
    func send_xchookToggleSwitched_true_shows_confirmation_alert() async {
        let sut = GeneralSettings(
            .testDependencies(xchookClient: availableXCHookClient()),
            xchookEnabled: false
        )
        await sut.send(.xchookToggleSwitched(true))
        #expect(sut.showingAlert)
        #expect(sut.alertType == .xchookWarning)
        #expect(sut.xchookEnabled == false)
    }

    @MainActor @Test
    func send_xchookInstallConfirmed_installs_without_restart_offer_when_xcode_not_running() async {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = GeneralSettings(
            .testDependencies(xchookClient: availableXCHookClient(installCallStack: callStack)),
            xchookEnabled: false
        )
        await sut.send(.xchookInstallConfirmed)
        #expect(callStack.withLock(\.self) == ["install"])
        #expect(sut.xchookEnabled)
        #expect(sut.showingAlert == false)
    }

    @MainActor @Test
    func send_xchookInstallConfirmed_offers_restart_when_xcode_running() async {
        let sut = GeneralSettings(
            .testDependencies(
                xchookClient: availableXCHookClient(),
                xcodeApplicationClient: testDependency(of: XcodeApplicationClient.self) {
                    $0.isRunning = { true }
                }
            ),
            xchookEnabled: false
        )
        await sut.send(.xchookInstallConfirmed)
        #expect(sut.xchookEnabled)
        #expect(sut.showingAlert)
        #expect(sut.alertType == .xcodeRestart)
    }

    @MainActor @Test
    func send_xchookInstallConfirmed_install_failure_shows_operationFailed() async {
        let sut = GeneralSettings(
            .testDependencies(
                xchookClient: availableXCHookClient(install: { throw TestError.operationFailed })
            ),
            xchookEnabled: false
        )
        await sut.send(.xchookInstallConfirmed)
        #expect(sut.xchookEnabled == false)
        #expect(sut.showingAlert)
        #expect(sut.alertType == .operationFailed)
    }

    @MainActor @Test
    func send_xchookToggleSwitched_false_uninstalls() async {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = GeneralSettings(
            .testDependencies(xchookClient: availableXCHookClient(installCallStack: callStack)),
            xchookEnabled: true
        )
        await sut.send(.xchookToggleSwitched(false))
        #expect(callStack.withLock(\.self) == ["uninstall"])
        #expect(sut.xchookEnabled == false)
        #expect(sut.showingAlert == false)
    }

    @MainActor @Test
    func send_xchookToggleSwitched_false_uninstall_failure_shows_operationFailed() async {
        let sut = GeneralSettings(
            .testDependencies(
                xchookClient: availableXCHookClient(uninstall: { throw TestError.operationFailed })
            ),
            xchookEnabled: true
        )
        await sut.send(.xchookToggleSwitched(false))
        #expect(sut.xchookEnabled)
        #expect(sut.showingAlert)
        #expect(sut.alertType == .operationFailed)
    }

    @MainActor @Test
    func send_xcodeRestartConfirmed_restarts_xcode() async {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = GeneralSettings(.testDependencies(
            xcodeApplicationClient: testDependency(of: XcodeApplicationClient.self) {
                $0.restart = {
                    callStack.withLock { $0.append("restart") }
                    return true
                }
            }
        ))
        await sut.send(.xcodeRestartConfirmed)
        #expect(callStack.withLock(\.self) == ["restart"])
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_registers_and_updates_state() async {
        let enabled = AllocatedUnfairLock<Bool>(initialState: false)
        let sut = GeneralSettings(.testDependencies(
            smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                $0.isEnabled = { enabled.withLock(\.self) }
                $0.register = { enabled.withLock { $0 = true } }
                $0.unregister = { enabled.withLock { $0 = false } }
            }
        ))
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchesAtLogin)
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_keeps_actual_status_when_register_fails() async {
        let sut = GeneralSettings(.testDependencies(
            smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                $0.isEnabled = { false }
                $0.register = { throw TestError.operationFailed }
            }
        ))
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchesAtLogin == false)
    }
}
