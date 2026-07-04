/*
 Binding+Extension.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import SwiftUI

extension Binding where Value : Sendable {
    @preconcurrency init(
        @_inheritActorContext get: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext asyncSet: @escaping @isolated(any) @Sendable (Value) async -> Void
    ) {
        self.init(get: get, set: { newValue in Task { await asyncSet(newValue) } })
    }
}
