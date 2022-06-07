//
//  EventHistory.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/06/07.
//

import Foundation

enum EventType: String {
    case buildSucceeded = "Build Succeeded"
    case buildFailed = "Build Failed"
    case testSucceeded = "Test Succeeded"
    case testFailed = "Test Failed"

    var imageName: String {
        switch self {
        case .buildSucceeded:   return "build-succeeded"
        case .buildFailed:      return "build-failed"
        case .testSucceeded:    return "test-succeeded"
        case .testFailed:       return "test-failed"
        }
    }
}

struct EventHistory {
    let project: String
    let eventType: EventType
    let elapsedTime: Double
}
