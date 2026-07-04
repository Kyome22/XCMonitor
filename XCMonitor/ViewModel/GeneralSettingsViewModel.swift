//
//  GeneralSettingsViewModel.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/02.
//

import SwiftUI
import XCHook
import ServiceManagement

final class GeneralSettingsViewModel: ObservableObject {
    enum AlertType {
        case xcodePlistNotFound
        case xchookWarning
        case xcodeRestart
        case operationFailed
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
            showAlert(of: .xcodePlistNotFound)
            return
        }
        if newValue {
            showAlert(of: .xchookWarning)
        } else {
            do {
                try xchook.uninstall()
                innerXchookEnabled = false
                offerXcodeRestartIfNeeded()
            } catch {
                xchookEnabled = innerXchookEnabled
                showAlert(of: .operationFailed)
            }
        }
    }

    func react(for userResponse: Bool) {
        guard let xchook = xchook, userResponse else {
            innerXchookEnabled = false
            xchookEnabled = innerXchookEnabled
            return
        }
        do {
            try xchook.install()
            innerXchookEnabled = true
            offerXcodeRestartIfNeeded()
        } catch {
            innerXchookEnabled = false
            xchookEnabled = innerXchookEnabled
            showAlert(of: .operationFailed)
        }
    }

    func restartXcode() {
        Task {
            await XcodeApplication.restart()
        }
    }

    private func offerXcodeRestartIfNeeded() {
        if XcodeApplication.isRunning {
            showAlert(of: .xcodeRestart)
        }
    }

    private func showAlert(of type: AlertType) {
        alertType = type
        DispatchQueue.main.async {
            self.showingAlert = true
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
