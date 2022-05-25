//
//  Extensions.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/01.
//

import Cocoa

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension NSStatusItem {
    static var `default`: NSStatusItem {
        return NSStatusBar.system.statusItem(withLength: Self.variableLength)
    }
}

extension NSMenuItem {
    convenience init(title: String, action: Selector) {
        self.init(title: title, action: action, keyEquivalent: "")
    }
}

extension NSAppearance {
    var isDark: Bool {
        if self.name == .vibrantDark { return true }
        guard #available(macOS 10.14, *) else { return false }
        return self.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}

extension Bool {
    var state: NSControl.StateValue {
        return self ? .on : .off
    }
}

extension NSControl.StateValue {
    var isOn: Bool {
        return self == .on
    }
}
