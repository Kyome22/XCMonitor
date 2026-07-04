/*
 GeneralSettings.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource
import Observation

@MainActor @Observable
public final class GeneralSettings: Composable {
    private let launchAtLoginRepository: LaunchAtLoginRepository
    private let logService: LogService
    private let xchookService: XCHookService
    private let xcodeApplicationClient: XcodeApplicationClient

    public var xchookEnabled: Bool
    public var launchesAtLogin: Bool
    public var showingAlert: Bool = false
    public var alertType: AlertType = .xcodePlistNotFound
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        xchookEnabled: Bool? = nil,
        launchesAtLogin: Bool? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.launchAtLoginRepository = .init(appDependencies.smAppServiceClient)
        self.logService = .init(appDependencies)
        self.xchookService = .init(appDependencies)
        self.xcodeApplicationClient = appDependencies.xcodeApplicationClient
        self.xchookEnabled = xchookEnabled ?? xchookService.isInstalled()
        self.launchesAtLogin = launchesAtLogin ?? launchAtLoginRepository.isEnabled
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case let .xchookToggleSwitched(isOn):
            guard isOn != xchookEnabled else { return }
            guard xchookService.isAvailable() else {
                showAlert(of: .xcodePlistNotFound)
                return
            }
            if isOn {
                showAlert(of: .xchookWarning)
            } else {
                uninstallXCHook()
            }

        case .xchookInstallConfirmed:
            installXCHook()

        case .xcodeRestartConfirmed:
            if await !xcodeApplicationClient.restart() {
                logService.error(.restartingXcodeFailed)
            }

        case let .launchAtLoginToggleSwitched(isOn):
            switch launchAtLoginRepository.switchStatus(isOn) {
            case .success:
                launchesAtLogin = isOn
            case let .failure(.switchFailed(value)):
                launchesAtLogin = value
            }
        }
    }

    private func installXCHook() {
        do {
            try xchookService.install()
            xchookEnabled = true
            offerXcodeRestartIfNeeded()
        } catch XCMError.xchookOperation(.xcodePlistNotFound) {
            showAlert(of: .xcodePlistNotFound)
        } catch {
            showAlert(of: .operationFailed)
        }
    }

    private func uninstallXCHook() {
        do {
            try xchookService.uninstall()
            xchookEnabled = false
            offerXcodeRestartIfNeeded()
        } catch XCMError.xchookOperation(.xcodePlistNotFound) {
            showAlert(of: .xcodePlistNotFound)
        } catch {
            showAlert(of: .operationFailed)
        }
    }

    private func offerXcodeRestartIfNeeded() {
        if xcodeApplicationClient.isRunning() {
            showAlert(of: .xcodeRestart)
        }
    }

    private func showAlert(of type: AlertType) {
        alertType = type
        showingAlert = true
    }

    public enum AlertType: Sendable {
        case xcodePlistNotFound
        case xchookWarning
        case xcodeRestart
        case operationFailed
    }

    public enum Action: Sendable {
        case task(String)
        case xchookToggleSwitched(Bool)
        case xchookInstallConfirmed
        case xcodeRestartConfirmed
        case launchAtLoginToggleSwitched(Bool)
    }
}
