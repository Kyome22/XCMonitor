/*
 EventType+Extension.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource
import Foundation

extension EventType {
    var imageName: String {
        switch self {
        case .buildSucceeded:
            "build-succeeded"
        case .buildFailed:
            "build-failed"
        case .testSucceeded:
            "test-succeeded"
        case .testFailed:
            "test-failed"
        }
    }

    var label: String {
        switch self {
        case .buildSucceeded:
            String(localized: "buildSucceeded", bundle: .module)
        case .buildFailed:
            String(localized: "buildFailed", bundle: .module)
        case .testSucceeded:
            String(localized: "testSucceeded", bundle: .module)
        case .testFailed:
            String(localized: "testFailed", bundle: .module)
        }
    }
}
