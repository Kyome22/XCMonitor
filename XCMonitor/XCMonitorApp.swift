/*
 XCMonitorApp.swift
 XCMonitor

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Model
import SwiftUI
import UserInterface

@main
struct XCMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarScene()
        SettingsScene()
        ErrorAlertScene()
    }
}
