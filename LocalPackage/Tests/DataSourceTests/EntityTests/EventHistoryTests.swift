import Foundation
import Testing
import XCHook

@testable import DataSource

struct EventHistoryTests {
    private func event(
        project: String = "Sample",
        path: String = "/tmp/Sample.xcodeproj",
        status: XCHookStatus,
        timestamp: Double
    ) -> XCHookEvent {
        XCHookEvent(project: project, path: path, status: status, timestamp: timestamp)
    }

    @Test func histories_buildPair_produces_buildSucceeded() {
        let events = [
            event(status: .buildStart, timestamp: 1),
            event(status: .buildSucceeds, timestamp: 3.5),
        ]
        #expect(EventHistory.histories(from: events) == [
            EventHistory(
                project: "Sample",
                eventType: .buildSucceeded,
                elapsedTime: 2.5,
                projectURL: URL(fileURLWithPath: "/tmp/Sample.xcodeproj")
            ),
        ])
    }

    @Test func histories_pairs_all_matching_status_combinations() {
        let events = [
            event(status: .buildStart, timestamp: 1),
            event(status: .buildFails, timestamp: 2),
            event(status: .testingStart, timestamp: 3),
            event(status: .testingSucceeds, timestamp: 4),
            event(status: .testingStart, timestamp: 5),
            event(status: .testingFails, timestamp: 6),
        ]
        #expect(EventHistory.histories(from: events).map(\.eventType) == [
            .buildFailed,
            .testSucceeded,
            .testFailed,
        ])
    }

    @Test func histories_differentProjects_are_not_paired() {
        let events = [
            event(project: "A", status: .buildStart, timestamp: 1),
            event(project: "B", status: .buildSucceeds, timestamp: 2),
        ]
        #expect(EventHistory.histories(from: events).isEmpty)
    }

    @Test func histories_unmatched_statuses_are_skipped() {
        let events = [
            event(status: .buildSucceeds, timestamp: 1),
            event(status: .buildStart, timestamp: 2),
            event(status: .buildSucceeds, timestamp: 4),
            event(status: .standby, timestamp: 5),
        ]
        #expect(EventHistory.histories(from: events).map(\.eventType) == [.buildSucceeded])
    }

    @Test func histories_emptyPath_produces_nil_projectURL() {
        let events = [
            event(path: "", status: .buildStart, timestamp: 1),
            event(path: "", status: .buildSucceeds, timestamp: 2),
        ]
        #expect(EventHistory.histories(from: events).map(\.projectURL) == [nil])
    }
}
