//
//  GeneralPaneModel.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/02.
//

import AppKit
import Combine
import XCHook
import ServiceManagement

final class GeneralPaneModel {
    private let xchook: XCHook?
    private let dataManager = DataManager.shared

    private let xchookCheckBoxStateSubject = PassthroughSubject<Bool, Never>()
    var xchookCheckBoxStatePublisher: AnyPublisher<Bool, Never> {
        return xchookCheckBoxStateSubject
            .prepend(xchook?.isInstalled() ?? false)
            .eraseToAnyPublisher()
    }

    private let alertSubject = PassthroughSubject<AlertType, Never>()
    var alertPublisher: AnyPublisher<AlertType, Never> {
        return alertSubject.eraseToAnyPublisher()
    }

    private let launchCheckBoxStateSubject = PassthroughSubject<Bool, Never>()
    var launchCheckBoxStatePublisher: AnyPublisher<Bool, Never> {
        return launchCheckBoxStateSubject
            .prepend(dataManager.launchAtLogin)
            .eraseToAnyPublisher()
    }

    init() {
        xchook = XCHook()
    }

    func toggleEnableXCHook(state: Bool) {
        guard let xchook = xchook else {
            xchookCheckBoxStateSubject.send(false)
            alertSubject.send(.xcodePlistNotFound)
            return
        }

        // Show an alert to quit Xcode.app if it is running.
        let isRunningXcode = NSWorkspace.shared.runningApplications
            .contains(where: { app in
                return app.bundleIdentifier == "com.apple.dt.Xcode"
                && app.localizedName == "Xcode"
            })
        if isRunningXcode {
            xchookCheckBoxStateSubject.send(state == false)
            alertSubject.send(.xcodeIsRunning)
            return
        }

        if state {
            alertSubject.send(.xchookWarning)
        } else {
            xchook.uninstall()
        }
    }

    func react(for userResponse: Bool) {
        if let xchook = xchook, userResponse {
            xchook.install()
        } else {
            xchookCheckBoxStateSubject.send(false)
        }
    }

    func toggleLaunchAppAtLogin(state: Bool) {
        if SMLoginItemSetEnabled("com.kyome.XCMonitorLauncher" as CFString, state) {
            dataManager.launchAtLogin = state
        } else {
            launchCheckBoxStateSubject.send(dataManager.launchAtLogin)
        }
    }
}
