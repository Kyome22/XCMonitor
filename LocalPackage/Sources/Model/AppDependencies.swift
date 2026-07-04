/*
 AppDependencies.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    // MIGRATION: Phase 2 adds one property per dependency client, alphabetical, all defaulting to .liveValue.
    public var appStateClient = AppStateClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue

    static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        // MIGRATION: Keep this parameter list in sync with the stored properties above.
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient
        )
    }
}
