//
//  main.swift
//  XCMonitorLauncher
//
//  Created by Takuto Nakamura on 2022/05/26.
//

import Cocoa

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
