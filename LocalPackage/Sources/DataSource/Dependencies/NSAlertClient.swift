/*
 NSAlertClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import AppKit

public struct NSAlertClient: DependencyClient {
    public var runModal: @MainActor @Sendable (NSAlert) -> NSApplication.ModalResponse

    public static let liveValue = Self(
        runModal: { $0.runModal() }
    )

    public static let testValue = Self(
        runModal: { _ in .alertFirstButtonReturn }
    )
}
