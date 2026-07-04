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
    public var appStateClient = AppStateClient.liveValue
    public var fileManagerClient = FileManagerClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var nsAlertClient = NSAlertClient.liveValue
    public var nsAppClient = NSAppClient.liveValue
    public var nsWorkspaceClient = NSWorkspaceClient.liveValue
    public var smAppServiceClient = SMAppServiceClient.liveValue
    public var xchookClient = XCHookClient.liveValue
    public var xchookReceiverClient = XCHookReceiverClient.liveValue
    public var xcodeApplicationClient = XcodeApplicationClient.liveValue

    public static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        fileManagerClient: FileManagerClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        nsAlertClient: NSAlertClient = .testValue,
        nsAppClient: NSAppClient = .testValue,
        nsWorkspaceClient: NSWorkspaceClient = .testValue,
        smAppServiceClient: SMAppServiceClient = .testValue,
        xchookClient: XCHookClient = .testValue,
        xchookReceiverClient: XCHookReceiverClient = .testValue,
        xcodeApplicationClient: XcodeApplicationClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            fileManagerClient: fileManagerClient,
            loggingSystemClient: loggingSystemClient,
            nsAlertClient: nsAlertClient,
            nsAppClient: nsAppClient,
            nsWorkspaceClient: nsWorkspaceClient,
            smAppServiceClient: smAppServiceClient,
            xchookClient: xchookClient,
            xchookReceiverClient: xchookReceiverClient,
            xcodeApplicationClient: xcodeApplicationClient
        )
    }
}
