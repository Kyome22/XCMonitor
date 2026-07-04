/*
 EventType.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

public enum EventType: String, Sendable {
    case buildSucceeded = "Build Succeeded"
    case buildFailed = "Build Failed"
    case testSucceeded = "Test Succeeded"
    case testFailed = "Test Failed"

    init?(start: XCHookStatus, finish: XCHookStatus) {
        switch (start, finish) {
        case (.buildStart, .buildSucceeds):
            self = .buildSucceeded
        case (.buildStart, .buildFails):
            self = .buildFailed
        case (.testingStart, .testingSucceeds):
            self = .testSucceeded
        case (.testingStart, .testingFails):
            self = .testFailed
        default:
            return nil
        }
    }
}
