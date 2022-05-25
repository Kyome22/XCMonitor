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
    private let menuBar = MenuBar()

    private var event: XCHookEvent
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
}

extension MenuBarModel: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(openProject(_:)) {
            return !event.path.isEmpty
        }
        return true
    }
}
