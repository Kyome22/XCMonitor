/*
 XCMError.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation

public enum XCMError: Error, Equatable {
    case xchookOperation(XCHookOperation)
    case xcodeProject(XcodeProject)

    public enum XCHookOperation: Error, Equatable {
        case xcodePlistNotFound
        case installFailed
        case uninstallFailed
    }

    public enum XcodeProject: Error, Equatable {
        case projectFileNotFound(String)
    }
}
