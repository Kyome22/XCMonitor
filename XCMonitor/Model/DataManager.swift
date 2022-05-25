//
//  DataManager.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/26.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let userDefaults = UserDefaults.standard

    var launchAtLogin: Bool {
        get { return userDefaults.bool(forKey: "launcher") }
        set { userDefaults.set(newValue, forKey: "launcher") }
    }

    private init() {
        userDefaults.register(defaults: ["launcher" : false])
    }
}
