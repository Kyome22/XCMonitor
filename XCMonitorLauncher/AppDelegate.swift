//
//  AppDelegate.swift
//  XCMonitorLauncher
//
//  Created by Takuto Nakamura on 2022/05/26.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppId = "com.kyome.XCMonitor"
        let workspace = NSWorkspace.shared
        let isRunning = workspace.runningApplications.contains { app in
            app.bundleIdentifier == mainAppId
        }
        if !isRunning, let url = workspace.urlForApplication(withBundleIdentifier: mainAppId) {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url, configuration: config) { _, _ in
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        } else {
            NSApp.terminate(nil)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
