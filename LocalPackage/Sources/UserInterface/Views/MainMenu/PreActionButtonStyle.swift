/*
 PreActionButtonStyle.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import SwiftUI

struct PreActionButtonStyle: PrimitiveButtonStyle {
    var preAction: () async -> Void

    init(preAction: @escaping () async -> Void) {
        self.preAction = preAction
    }

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            Task {
                await preAction()
                configuration.trigger()
            }
        } label: {
            configuration.label
        }
    }
}

extension PrimitiveButtonStyle where Self == PreActionButtonStyle {
    static func preAction(perform action: @escaping () async -> Void) -> PreActionButtonStyle {
        PreActionButtonStyle(preAction: action)
    }
}
