/*
 AppState.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation

public struct AppState: Sendable {
    public var hasAlreadyBootstrap: Bool

    init(hasAlreadyBootstrap: Bool = false) {
        self.hasAlreadyBootstrap = hasAlreadyBootstrap
    }
}
