/*
 MenuBarIconView.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Model
import SwiftUI

struct MenuBarIconView: View {
    @StateObject var store: MainMenu

    var body: some View {
        Image(store.currentEvent.status.imageName, bundle: .module)
            .task {
                await store.send(.task(String(describing: Self.self)))
            }
    }
}
