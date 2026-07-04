/*
 XCHookClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

public struct XCHookClient: DependencyClient {
    public var make: @Sendable () -> XCHook?
    public var isInstalled: @Sendable (XCHook) -> Bool
    public var install: @Sendable (XCHook) throws -> Void
    public var uninstall: @Sendable (XCHook) throws -> Void

    public static let liveValue = Self(
        make: { XCHook() },
        isInstalled: { $0.isInstalled() },
        install: { try $0.install() },
        uninstall: { try $0.uninstall() }
    )

    public static let testValue = Self(
        make: { nil },
        isInstalled: { _ in false },
        install: { _ in },
        uninstall: { _ in }
    )
}
