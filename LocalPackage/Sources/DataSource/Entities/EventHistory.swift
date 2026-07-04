/*
 EventHistory.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation
import XCHook

public struct EventHistory: Sendable, Hashable {
    public let project: String
    public let eventType: EventType
    public let elapsedTime: Double
    public let projectURL: URL?

    public static func histories(from events: [XCHookEvent]) -> [EventHistory] {
        var histories = [EventHistory]()
        var index = 0
        while index < events.count - 1 {
            let startEvent = events[index]
            let finishEvent = events[index + 1]
            guard startEvent.project == finishEvent.project,
                  let eventType = EventType(start: startEvent.status, finish: finishEvent.status) else {
                index += 1
                continue
            }
            histories.append(EventHistory(
                project: startEvent.project,
                eventType: eventType,
                elapsedTime: finishEvent.timestamp - startEvent.timestamp,
                projectURL: startEvent.path.isEmpty ? nil : URL(fileURLWithPath: startEvent.path)
            ))
            index += 2
        }
        return histories
    }
}
