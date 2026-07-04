import AllocatedUnfairLock
import Testing

@testable import DataSource
@testable import Model

private enum TestError: Error {
    case operationFailed
}

struct XCHookServiceTests {
    @Test func install_throws_xcodePlistNotFound_when_xchook_unavailable() {
        let sut = XCHookService(.testDependencies())
        #expect(throws: XCMError.xchookOperation(.xcodePlistNotFound)) {
            try sut.install()
        }
    }

    @Test func install_throws_installFailed_when_client_throws() {
        let sut = XCHookService(.testDependencies(
            xchookClient: testDependency(of: XCHookClient.self) {
                $0.isAvailable = { true }
                $0.install = { throw TestError.operationFailed }
            }
        ))
        #expect(throws: XCMError.xchookOperation(.installFailed)) {
            try sut.install()
        }
    }

    @Test func install_calls_client_install() throws {
        let callStack = AllocatedUnfairLock<[String]>(initialState: [])
        let sut = XCHookService(.testDependencies(
            xchookClient: testDependency(of: XCHookClient.self) {
                $0.isAvailable = { true }
                $0.install = {
                    callStack.withLock { $0.append("install") }
                }
            }
        ))
        try sut.install()
        #expect(callStack.withLock(\.self) == ["install"])
    }

    @Test func uninstall_throws_uninstallFailed_when_client_throws() {
        let sut = XCHookService(.testDependencies(
            xchookClient: testDependency(of: XCHookClient.self) {
                $0.isAvailable = { true }
                $0.uninstall = { throw TestError.operationFailed }
            }
        ))
        #expect(throws: XCMError.xchookOperation(.uninstallFailed)) {
            try sut.uninstall()
        }
    }

    @Test func isInstalled_reflects_client_state() {
        let sut = XCHookService(.testDependencies(
            xchookClient: testDependency(of: XCHookClient.self) {
                $0.isInstalled = { true }
            }
        ))
        #expect(sut.isInstalled())
    }
}
