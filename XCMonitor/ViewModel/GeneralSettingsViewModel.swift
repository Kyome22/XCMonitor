//
//  GeneralSettingsViewModel.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/02.
//

import SwiftUI
import Combine
import XCHook
import ServiceManagement

final class GeneralSettingsViewModel: ObservableObject {
    enum AlertType {
        case xcodePlistNotFound
        case xcodeIsRunning
        case xchookWarning
    }

    var innerXchookEnabled: Bool = false
    @Published var xchookEnabled: Bool
    var innerLaunchAtLogin: Bool = false
    @Published var launchAtLogin: Bool
    @Published var showingAlert: Bool = false
    var alertType: AlertType = .xcodePlistNotFound

    private let xchook: XCHook?

    init() {
        xchook = XCHook()
        innerXchookEnabled = xchook?.isInstalled() ?? false
        xchookEnabled = innerXchookEnabled
        let jobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd)
            .takeRetainedValue() as NSArray as! [[String:AnyObject]]
        innerLaunchAtLogin = jobDicts.contains { dict in
            return dict["Label"] as! String == "com.kyome.XCMonitorLauncher"
        }
        launchAtLogin = innerLaunchAtLogin
    }

    func toggleXCHookEnabled(_ newValue: Bool) {
        if newValue == innerXchookEnabled {
            return
        }
        guard let xchook = xchook else {
            innerXchookEnabled = false
            xchookEnabled = innerXchookEnabled
            showingAlert = true
            alertType = .xcodePlistNotFound
            return
        }

        // Show an alert to quit Xcode.app if it is running.
        let isRunningXcode = NSWorkspace.shared.runningApplications
            .contains(where: { app in
                return app.bundleIdentifier == "com.apple.dt.Xcode"
                && app.localizedName == "Xcode"
            })
        if isRunningXcode {
            xchookEnabled = innerXchookEnabled
            showingAlert = true
            alertType = .xcodeIsRunning
            return
        }

        if newValue {
            showingAlert = true
            alertType = .xchookWarning
        } else {
            xchook.uninstall()
        }
    }

    func react(for userResponse: Bool) {
        if let xchook = xchook, userResponse {
            innerXchookEnabled = true
            xchook.install()
        } else {
            innerXchookEnabled = false
            xchookEnabled = innerXchookEnabled
        }
    }

    func toggleLaunchAtLogin(_ newValue: Bool) {
        if newValue == innerLaunchAtLogin {
            return
        }
        if SMLoginItemSetEnabled("com.kyome.XCMonitorLauncher" as CFString, newValue) {
            innerLaunchAtLogin = newValue
        } else {
            launchAtLogin = innerLaunchAtLogin
        }
    }
}
