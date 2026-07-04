/*
 FileManagerClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Foundation

public struct FileManagerClient: DependencyClient {
    public var fileExists: @Sendable (String) -> Bool

    public static let liveValue = Self(
        fileExists: { FileManager.default.fileExists(atPath: $0) }
    )

    public static let testValue = Self(
        fileExists: { _ in false }
    )
}
