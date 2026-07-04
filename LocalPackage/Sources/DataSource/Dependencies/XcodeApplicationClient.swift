/*
 XcodeApplicationClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

public struct XcodeApplicationClient: DependencyClient {
    public var isRunning: @Sendable () -> Bool
    public var restart: @Sendable () async -> Bool

    public static let liveValue = Self(
        isRunning: { XcodeApplication.isRunning },
        restart: { await XcodeApplication.restart() }
    )

    public static let testValue = Self(
        isRunning: { false },
        restart: { false }
    )
}
