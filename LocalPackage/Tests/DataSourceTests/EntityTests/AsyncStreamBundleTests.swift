import Testing

@testable import DataSource

struct AsyncStreamBundleTests {
    @Test func send_updates_latestValue() {
        var bundle = AsyncStreamBundle<Int>()
        #expect(bundle.latestValue == nil)
        bundle.send(42)
        #expect(bundle.latestValue == 42)
    }
}
