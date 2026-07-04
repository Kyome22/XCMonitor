/*
 NSAppClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import AppKit

public struct NSAppClient: DependencyClient {
    public var activate: @MainActor @Sendable (Bool) -> Void
    public var terminate: @MainActor @Sendable (Any?) -> Void
    public var orderFrontStandardAboutPanel: @MainActor @Sendable (Any?) -> Void

    public static let liveValue = Self(
        activate: { NSApp.activate(ignoringOtherApps: $0) },
        terminate: { NSApp.terminate($0) },
        orderFrontStandardAboutPanel: { NSApp.orderFrontStandardAboutPanel($0) }
    )

    public static let testValue = Self(
        activate: { _ in },
        terminate: { _ in },
        orderFrontStandardAboutPanel: { _ in }
    )
}
