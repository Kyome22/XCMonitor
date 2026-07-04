/*
 MainMenu.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import AppKit
import DataSource
import Observation
import XCHook

@MainActor @Observable
public final class MainMenu: Composable {
    private let fileManagerClient: FileManagerClient
    private let nsAlertClient: NSAlertClient
    private let nsAppClient: NSAppClient
    private let nsWorkspaceClient: NSWorkspaceClient
    private let xchookReceiverClient: XCHookReceiverClient
    private let logService: LogService

    private let xcodeBundleIdentifier = "com.apple.dt.Xcode"
    private let maxEventCount = 50

    @ObservationIgnored private var tasks = [Task<Void, Never>]()
    @ObservationIgnored private var eventList = [XCHookEvent]()

    public var currentEvent: XCHookEvent
    public var eventHistories: [EventHistory]
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        currentEvent: XCHookEvent? = nil,
        eventHistories: [EventHistory]? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.fileManagerClient = appDependencies.fileManagerClient
        self.nsAlertClient = appDependencies.nsAlertClient
        self.nsAppClient = appDependencies.nsAppClient
        self.nsWorkspaceClient = appDependencies.nsWorkspaceClient
        self.xchookReceiverClient = appDependencies.xchookReceiverClient
        self.logService = .init(appDependencies)
        self.currentEvent = currentEvent ?? .standby
        self.eventHistories = eventHistories ?? []
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            tasks.forEach { $0.cancel() }
            tasks = [
                Task { [weak self, xchookReceiverClient] in
                    for await event in xchookReceiverClient.events() {
                        await self?.send(.xchookEventReceived(event))
                    }
                },
                Task { [weak self, nsWorkspaceClient] in
                    for await bundleIdentifier in nsWorkspaceClient.terminatedApplications() {
                        await self?.send(.applicationTerminated(bundleIdentifier))
                    }
                },
            ]

        case .onDisappear:
            tasks.forEach { $0.cancel() }
            tasks = []

        case let .xchookEventReceived(event):
            eventList.append(event)
            eventList.sort { $0.timestamp < $1.timestamp }
            if maxEventCount < eventList.count {
                eventList.removeFirst()
            }
            eventHistories = EventHistory.histories(from: eventList).reversed()
            if currentEvent.timestamp < event.timestamp {
                currentEvent = event
            }

        case let .applicationTerminated(bundleIdentifier):
            if bundleIdentifier == xcodeBundleIdentifier {
                currentEvent = .standby
            }

        case .openProjectButtonTapped:
            guard !currentEvent.path.isEmpty else { return }
            await openXcodeProject(with: URL(fileURLWithPath: currentEvent.path))

        case let .historyButtonTapped(eventHistory):
            guard let projectURL = eventHistory.projectURL else { return }
            await openXcodeProject(with: projectURL)

        case .settingsLinkPreActionTriggered:
            nsAppClient.activate(true)

        case .aboutButtonTapped:
            nsAppClient.activate(true)
            nsAppClient.orderFrontStandardAboutPanel(nil)

        case .quitButtonTapped:
            nsAppClient.terminate(nil)
        }
    }

    private func openXcodeProject(with url: URL) async {
        guard fileManagerClient.fileExists(url.path) else {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = String(localized: "projectNotOpenMessage\(url.lastPathComponent)", bundle: .module)
            alert.informativeText = String(localized: "projectNotOpenInformative", bundle: .module)
            _ = nsAlertClient.runModal(alert)
            return
        }
        guard let xcodeURL = nsWorkspaceClient.urlForApplication(xcodeBundleIdentifier) else {
            logService.error(.xcodeApplicationNotFound)
            return
        }
        do {
            try await nsWorkspaceClient.open([url], xcodeURL)
        } catch {
            logService.error(.openingXcodeProjectFailed(error))
        }
    }

    public enum Action: Sendable {
        case task(String)
        case onDisappear
        case xchookEventReceived(XCHookEvent)
        case applicationTerminated(String)
        case openProjectButtonTapped
        case historyButtonTapped(EventHistory)
        case settingsLinkPreActionTriggered
        case aboutButtonTapped
        case quitButtonTapped
    }
}
