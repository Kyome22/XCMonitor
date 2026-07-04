/*
 ErrorEvent.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation
import Logging

public enum ErrorEvent {
    case openingXcodeProjectFailed(any Error)
    case restartingXcodeFailed
    case xcodeApplicationNotFound

    public var message: Logger.Message {
        switch self {
        case .openingXcodeProjectFailed:
            "Failed to open the Xcode project."
        case .restartingXcodeFailed:
            "Failed to restart Xcode."
        case .xcodeApplicationNotFound:
            "Xcode application is not found."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case let .openingXcodeProjectFailed(error):
            ["cause": "\(error.localizedDescription)"]
        case .restartingXcodeFailed, .xcodeApplicationNotFound:
            nil
        }
    }
}
