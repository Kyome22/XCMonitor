/*
 MenuBarScene.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Model
import SwiftUI

public struct MenuBarScene: Scene {
    @State private var store = MainMenu(AppDependencies.shared)

    public init() {}

    public var body: some Scene {
        MenuBarExtra {
            MainMenuView(store: store)
        } label: {
            MenuBarIconView(store: store)
        }
    }
}
