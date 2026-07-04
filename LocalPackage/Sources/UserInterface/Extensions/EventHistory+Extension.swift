/*
 EventHistory+Extension.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource
import Foundation

extension EventHistory {
    var menuTitle: String {
        String(
            format: String(localized: "historyTitleFormat", bundle: .module),
            project,
            eventType.label,
            elapsedTime
        )
    }
}
