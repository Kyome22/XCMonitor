//
//  Alert.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/02.
//

import Cocoa

enum AlertType: Equatable {
    case xcodePlistNotFound
    case xcodeIsRunning
    case xchookWarning
    case projectCouldNotOpen(String)
}

final class Alert {
    static func show(alertType: AlertType, window: NSWindow? = nil, callback: ((Bool) -> Void)? = nil) {
        let alert = NSAlert()
        switch alertType {
        case .xcodePlistNotFound:
            alert.alertStyle = .critical
            alert.messageText = "plistNotFoundMessage".localized
            alert.informativeText = "plistNotFoundInformative".localized
        case .xcodeIsRunning:
            alert.alertStyle = .critical
            alert.messageText = "xcodeIsRunningMessage".localized
            alert.informativeText = "xcodeIsRunningInformative".localized
        case .xchookWarning:
            alert.alertStyle = .warning
            alert.messageText = "xchookConfirmMessage".localized
            alert.informativeText = "xchookConfirmInformative".localized
            alert.addButton(withTitle: "xchookConfirmEnable".localized)
            alert.addButton(withTitle: "xchookConfirmCancel".localized)
        case .projectCouldNotOpen(let projectFile):
            alert.alertStyle = .warning
            alert.messageText = "projectNotOpenMessage".localized
                .replacingOccurrences(of: "PROJECT_FILE", with: projectFile)
            alert.informativeText = "projectNotOpenInformative".localized
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
