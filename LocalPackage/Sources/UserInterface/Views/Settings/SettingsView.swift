/*
 SettingsView.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.appDependencies) private var appDependencies

    var body: some View {
        TabView {
            GeneralSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("general", bundle: .module)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
        }
        .fixedSize()
    }
}
