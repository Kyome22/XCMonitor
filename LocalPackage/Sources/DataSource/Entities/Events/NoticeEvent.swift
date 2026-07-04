/*
 NoticeEvent.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Logging

public enum NoticeEvent {
    case launchApp
    case screenView(name: String)

    public var message: Logger.Message {
        switch self {
        case .launchApp:
            "launch_app"
        case .screenView:
            "screen_view"
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case .launchApp:
            [:]
        case let .screenView(name):
            ["screen": .string(name)]
        }
    }
}
