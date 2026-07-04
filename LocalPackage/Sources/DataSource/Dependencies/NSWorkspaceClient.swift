/*
 NSWorkspaceClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import AppKit

public struct NSWorkspaceClient: DependencyClient {
    public var urlForApplication: @Sendable (String) -> URL?
    public var open: @Sendable ([URL], URL) async throws -> Void
    public var terminatedApplications: @Sendable () -> AsyncStream<String>

    public static let liveValue = Self(
        urlForApplication: { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) },
        open: { _ = try await NSWorkspace.shared.open($0, withApplicationAt: $1, configuration: .init()) },
        terminatedApplications: {
            AsyncStream { continuation in
                nonisolated(unsafe) let observer = NSWorkspace.shared.notificationCenter.addObserver(
                    forName: NSWorkspace.didTerminateApplicationNotification,
                    object: nil,
                    queue: nil
                ) { notification in
                    let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                    if let bundleIdentifier = application?.bundleIdentifier {
                        continuation.yield(bundleIdentifier)
                    }
                }
                continuation.onTermination = { _ in
                    NSWorkspace.shared.notificationCenter.removeObserver(observer)
                }
            }
        }
    )

    public static let testValue = Self(
        urlForApplication: { _ in nil },
        open: { _, _ in },
        terminatedApplications: { AsyncStream { $0.finish() } }
    )
}
