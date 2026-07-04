/*
 XCHookReceiverClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

public struct XCHookReceiverClient: DependencyClient {
    public var events: @Sendable () -> any AsyncSequence<XCHookEvent, Never> & Sendable

    public static let liveValue = Self(
        events: { XCHookReceiver.events }
    )

    public static let testValue = Self(
        events: { AsyncStream<XCHookEvent> { $0.finish() } }
    )
}
