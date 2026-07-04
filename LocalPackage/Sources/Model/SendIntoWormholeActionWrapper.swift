/*
 SendIntoWormholeActionWrapper.swift
 Model

 Created by Takuto Nakamura on 2026/07/05.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation

public struct SendIntoWormholeActionWrapper: Sendable {
    var action: (@MainActor @Sendable (String, Bool) -> Void)?

    public init(action: @escaping @MainActor @Sendable (String, Bool) -> Void) {
        self.action = action
    }

    @MainActor func callAsFunction(id: String, value: Bool) {
        action?(id, value)
    }
}
