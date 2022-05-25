//
//  MenuBar.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/01.
//

import Cocoa
import Combine
import XCHook

final class MenuBar {
    private let statusItem = NSStatusItem.default
    private let button: NSStatusBarButton
    private let menu = NSMenu()
    private let projectItem: NSMenuItem

    var isDark: Bool {
        return button.superview!.effectiveAppearance.isDark
    }
    var isDarkPublisher: AnyPublisher<NSAppearance, Never> {
        return button.superview!
            .publisher(for: \.effectiveAppearance, options: .new)
            .eraseToAnyPublisher()
    }

    init() {
        button = statusItem.button!
        let isDark = button.superview!.effectiveAppearance.isDark
        let imageName = isDark ? "standby-dark" : "standby-light"
        button.image = NSImage(named: imageName)

        statusItem.menu = menu

        projectItem = NSMenuItem(
            title: "noProject".localized,
            action: #selector(MenuBarModel.openProject(_:))
        )
        menu.addItem(projectItem)
        menu.addItem(NSMenuItem.separator())

        let preferencesItem = NSMenuItem(
            title: "preferences".localized,
            action: #selector(AppDelegate.openPreferences(_:))
        )
        menu.addItem(preferencesItem)
        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(
            title: "aboutApp".localized,
            action: #selector(AppDelegate.openAbout(_:))
        )
        menu.addItem(aboutItem)

        let terminateItem = NSMenuItem(
            title: "terminateApp".localized,
            action: #selector(NSApp.terminate(_:))
        )
        menu.addItem(terminateItem)
    }

    func setTarget(_ target: MenuBarModel) {
        projectItem.target = target
    }

    func updateStatus(event: XCHookEvent, isDark: Bool) {
        projectItem.title = "Show \(event.project) Project on Xcode"

        var imageName: String = ""
        switch event.status {
        case .standby:          imageName = "standby"
        case .buildStart:       imageName = "build-start"
        case .buildSucceeds:    imageName = "build-succeeds"
        case .buildFails:       imageName = "build-fails"
        case .testingStart:     imageName = "testing-start"
        case .testingSucceeds:  imageName = "testing-succeeds"
        case .testingFails:     imageName = "testing-fails"
        }
        imageName += isDark ? "-dark" : "-light"
        button.image = NSImage(named: imageName)
    }
}
