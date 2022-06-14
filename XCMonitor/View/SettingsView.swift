//
//  SettingsView.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/06/11.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
    }

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("general", systemImage: "gear")
                }
                .tag(Tabs.general)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
