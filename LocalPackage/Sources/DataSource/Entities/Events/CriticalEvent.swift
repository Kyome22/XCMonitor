/*
 CriticalEvent.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation
import Logging

public enum CriticalEvent {
    case setupFailed(any Error)
    case unknown(any Error)

    public var message: Logger.Message {
        switch self {
        case .setupFailed:
            "Failed to setup."
        case .unknown:
            "An unknown error has occurred."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case let .setupFailed(error),
            let .unknown(error):
            ["cause": "\(error.localizedDescription)"]
        }
    }
}
