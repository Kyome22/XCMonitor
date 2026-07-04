/*
 LaunchAtLoginRepository.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

public struct LaunchAtLoginRepository: Sendable {
    private let smAppServiceClient: SMAppServiceClient

    public var isEnabled: Bool {
        smAppServiceClient.isEnabled()
    }

    public init(_ smAppServiceClient: SMAppServiceClient) {
        self.smAppServiceClient = smAppServiceClient
    }

    public func switchStatus(_ isOn: Bool) -> Result<Void, SwitchError> {
        do {
            if isOn {
                try smAppServiceClient.register()
            } else {
                try smAppServiceClient.unregister()
            }
        } catch {
            let current = smAppServiceClient.isEnabled()
            return .failure(.switchFailed(current))
        }
        let current = smAppServiceClient.isEnabled()
        if current != isOn {
            return .failure(.switchFailed(current))
        }
        return .success(())
    }

    public enum SwitchError: Error, Equatable {
        case switchFailed(Bool)
    }
}
