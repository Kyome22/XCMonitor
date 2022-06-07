//
//  MenuBarModel.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/01.
//

import Cocoa
import Combine
import XCHook

final class MenuBarModel: NSObject {
    private let MAX_EVENTS: Int = 50
    private let menuBar = MenuBar()

    private var event: XCHookEvent
    private var eventList = [XCHookEvent]()
    private var isDark: Bool
    private var cancellables = Set<AnyCancellable>()

    override init() {
        event = XCHookEvent(project: "",
                            path: "",
                            status: .standby,
                            timestamp: "0.0")
        isDark = menuBar.isDark
        super.init()

        menuBar.setTarget(self)

        menuBar.isDarkPublisher
            .sink { [weak self] appearance in
                guard let self = self else { return }
                self.isDark = appearance.isDark
                self.menuBar.updateStatus(event: self.event, isDark: self.isDark)
            }
            .store(in: &cancellables)

        XCHookReceiver.shared.xchookPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                self.addEvent(event)
                if self.event.timestamp < event.timestamp {
                    self.event = event
                    self.menuBar.updateStatus(event: self.event, isDark: self.isDark)
                }
            }
            .store(in: &cancellables)
    }

    @IBAction func openProject(_ sender: Any?) {
        if event.path.isEmpty { return }
        let projectURL = URL(fileURLWithPath: event.path)
        if let xcodeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([projectURL], withApplicationAt: xcodeURL, configuration: config)
        }
    }

    @IBAction func dummyAction(_ sender: Any?) {}

    private func addEvent(_ event: XCHookEvent) {
        eventList.append(event)
        eventList.sort { $0.timestamp < $1.timestamp }
        if MAX_EVENTS < eventList.count {
            eventList.removeFirst()
        }
        var eventHistories = [EventHistory]()
        var i: Int = 0
        while i < eventList.count - 1 {
            let event0 = eventList[i]
            let event1 = eventList[i + 1]
            if event0.project != event1.project {
                i += 1
                continue
            }
            let eventType: EventType
            switch (event0.status, event1.status) {
            case (.buildStart, .buildSucceeds):
                eventType = .buildSucceeded
            case (.buildStart, .buildFails):
                eventType = .buildFailed
            case (.testingStart, .testingSucceeds):
                eventType = .testSucceeded
            case (.testingStart, .testingFails):
                eventType = .testFailed
            default:
                i += 1
                continue
            }
            let elapsedTime = event1.timestamp - event0.timestamp
            eventHistories.append(EventHistory(project: event0.project,
                                               eventType: eventType,
                                               elapsedTime: elapsedTime))
            i += 2
        }
        menuBar.updateEventHistories(eventHistories.reversed())
    }
}

extension MenuBarModel: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(openProject(_:)) {
            return !event.path.isEmpty
        }
        return true
    }
}
