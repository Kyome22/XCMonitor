/*
 XCHookClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

public struct XCHookClient: DependencyClient {
    public var isAvailable: @Sendable () -> Bool
    public var isInstalled: @Sendable () -> Bool
    public var install: @Sendable () throws -> Void
    public var uninstall: @Sendable () throws -> Void

    public static let liveValue = Self(
        isAvailable: { XCHook() != nil },
        isInstalled: { XCHook()?.isInstalled() ?? false },
        install: {
            guard let xchook = XCHook() else {
                throw ClientError.xchookUnavailable
            }
            try xchook.install()
        },
        uninstall: {
            guard let xchook = XCHook() else {
                throw ClientError.xchookUnavailable
            }
            try xchook.uninstall()
        }
    )

    public static let testValue = Self(
        isAvailable: { false },
        isInstalled: { false },
        install: {},
        uninstall: {}
    )

    public enum ClientError: Error {
        case xchookUnavailable
    }
}
