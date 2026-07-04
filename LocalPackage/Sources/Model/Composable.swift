/*
 Composable.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Observation

@MainActor
public protocol Composable: AnyObject {
    associatedtype Action: Sendable

    var action: (Action) async -> Void { get }

    func reduce(_ action: Action) async
}

public extension Composable {
    func reduce(_ action: Action) async {}

    func send(_ action: Action) async {
        await reduce(action)
        await self.action(action)
    }
}
