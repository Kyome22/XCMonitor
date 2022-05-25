//
//  AppDelegate.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/01.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesWC: NSWindowController?
    private var menuBarModel: MenuBarModel!

    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menuBarModel = MenuBarModel()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func openPreferences(_ sender: Any?) {
        if preferencesWC == nil {
            let sb = NSStoryboard(name: "PreferencesTab", bundle: nil)
            let wc = (sb.instantiateInitialController() as! NSWindowController)
            wc.window?.delegate = self
            wc.window?.isMovableByWindowBackground = true
            preferencesWC = wc
        }
        NSApp.activate(ignoringOtherApps: true)
        preferencesWC?.showWindow(nil)
    }

    @IBAction func openAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === preferencesWC?.window {
            preferencesWC = nil
        }
    }
}
