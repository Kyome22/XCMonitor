//
//  Alert.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/02.
//

import Cocoa

enum AlertType {
    case xcodePlistNotFound
    case xcodeIsRunning
    case xchookWarning
}

final class Alert {
    static func show(alertType: AlertType, window: NSWindow? = nil, callback: ((Bool) -> Void)? = nil) {
        let alert = NSAlert()
        switch alertType {
        case .xcodePlistNotFound:
            alert.alertStyle = .critical
            alert.messageText = "Xcode.plist Not Found"
            alert.informativeText = "XCMonitor cannot be used unless Xcode.app is installed and accessible."
        case .xcodeIsRunning:
            alert.alertStyle = .critical
            alert.messageText = "Xcode.app Is Running"
            alert.informativeText = "This operation cannot be performed while Xcode.app is running. Please quit Xcode.app."
        case .xchookWarning:
            alert.alertStyle = .warning
            alert.messageText = "Confirmation"
            alert.informativeText = "Enabling XCHook will overwrite scripts already set in Xcode Behaviors."
            alert.addButton(withTitle: "Enable")
            alert.addButton(withTitle: "Cancel")
        }
        if let window = window {
            alert.beginSheetModal(for: window) { response in
                callback?(response == .alertFirstButtonReturn)
            }
        } else {
            let response = alert.runModal()
            callback?(response == .alertFirstButtonReturn)
        }
    }
}
