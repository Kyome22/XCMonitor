import AllocatedUnfairLock
import Testing

@testable import DataSource
@testable import Model

struct LogServiceTests {
    @Test func bootstrap_sets_hasAlreadyBootstrap() {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let appDependencies = AppDependencies.testDependencies(
            appStateClient: .testDependency(appState)
        )
        let logService = LogService(appDependencies)
        logService.bootstrap()
        #expect(appState.withLock { $0.hasAlreadyBootstrap })
    }
}
