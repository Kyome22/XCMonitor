/*
 SettingsScene.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import SwiftUI

public struct SettingsScene: Scene {
    public init() {}

    public var body: some Scene {
        Settings {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
