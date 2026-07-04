/*
 LogService.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation
import DataSource
import Logging

struct LogService {
    private let appStateClient: AppStateClient
    private let loggingSystemClient: LoggingSystemClient

    init(_ appDependencies: AppDependencies) {
        self.appStateClient = appDependencies.appStateClient
        self.loggingSystemClient = appDependencies.loggingSystemClient
    }

    func bootstrap() {
        guard !appStateClient.withLock(\.hasAlreadyBootstrap) else {
            return
        }
#if DEBUG
        loggingSystemClient.bootstrap { label in
            StreamLogHandler.standardOutput(label: label)
        }
#endif
        appStateClient.withLock { $0.hasAlreadyBootstrap = true }
    }

    nonisolated func notice(
        _ event: NoticeEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName).notice(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    nonisolated func error(
        _ event: ErrorEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName).error(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    nonisolated func critical(
        _ event: CriticalEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName).critical(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }
}
