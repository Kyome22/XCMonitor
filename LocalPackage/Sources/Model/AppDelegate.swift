/*
 AppDelegate.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import AppKit
import DataSource

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appDependencies = AppDependencies.shared

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let logService = LogService(appDependencies)
        logService.bootstrap()
        logService.notice(.launchApp)
    }
}
