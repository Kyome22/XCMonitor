/*
 XCHookService.swift
 Model

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource

struct XCHookService {
    private let xchookClient: XCHookClient

    init(_ appDependencies: AppDependencies) {
        self.xchookClient = appDependencies.xchookClient
    }

    func isAvailable() -> Bool {
        xchookClient.isAvailable()
    }

    func isInstalled() -> Bool {
        xchookClient.isInstalled()
    }

    func install() throws {
        guard xchookClient.isAvailable() else {
            throw XCMError.xchookOperation(.xcodePlistNotFound)
        }
        do {
            try xchookClient.install()
        } catch {
            throw XCMError.xchookOperation(.installFailed)
        }
    }

    func uninstall() throws {
        guard xchookClient.isAvailable() else {
            throw XCMError.xchookOperation(.xcodePlistNotFound)
        }
        do {
            try xchookClient.uninstall()
        } catch {
            throw XCMError.xchookOperation(.uninstallFailed)
        }
    }
}
