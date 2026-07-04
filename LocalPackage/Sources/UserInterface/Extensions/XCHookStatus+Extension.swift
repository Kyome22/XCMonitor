/*
 XCHookStatus+Extension.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import XCHook

extension XCHookStatus {
    var imageName: String {
        switch self {
        case .standby:
            "standby"
        case .buildStart:
            "build-start"
        case .buildSucceeds:
            "build-succeeds"
        case .buildFails:
            "build-fails"
        case .testingStart:
            "testing-start"
        case .testingSucceeds:
            "testing-succeeds"
        case .testingFails:
            "testing-fails"
        }
    }
}
