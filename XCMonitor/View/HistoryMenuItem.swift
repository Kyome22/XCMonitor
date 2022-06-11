//
//  HistoryMenuItem.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/06/11.
//

import AppKit

final class HistoryMenuItem: NSMenuItem {
    let projectURL: URL?

    init(title: String, projectURL: URL?, image: NSImage?, target: AnyObject?, action: Selector) {
        self.projectURL = projectURL
        super.init(title: title, action: action, keyEquivalent: "")
        self.image = image
        self.target = target
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
