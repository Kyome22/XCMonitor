//
//  XCMonitorApp.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/06/11.
//

import SwiftUI

@main
struct XCMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
