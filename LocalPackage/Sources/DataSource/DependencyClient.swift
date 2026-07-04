/*
 DependencyClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

public protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}

public func testDependency<D: DependencyClient>(of type: D.Type, injection: (inout D) -> Void) -> D {
    var dependencyClient = type.testValue
    injection(&dependencyClient)
    return dependencyClient
}
