/*
 GeneralSettingsView.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Model
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject var store: GeneralSettings

    var body: some View {
        Form {
            HStack {
                VStack(alignment: .trailing, spacing: 8) {
                    Text(verbatim: "XCHook:")
                    Text("startup", bundle: .module)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding<Bool>(
                        get: { store.xchookEnabled },
                        asyncSet: { await store.send(.xchookToggleSwitched($0)) }
                    )) {
                        Text("enableScripts", bundle: .module)
                    }
                    .disabled(store.showingAlert)
                    Toggle(isOn: Binding<Bool>(
                        get: { store.launchesAtLogin },
                        asyncSet: { await store.send(.launchAtLoginToggleSwitched($0)) }
                    )) {
                        Text("launchAtLogin", bundle: .module)
                    }
                }
            }
        }
        .fixedSize()
        .padding(20)
        .alert(isPresented: $store.showingAlert) {
            switch store.alertType {
            case .xcodePlistNotFound:
                return Alert(
                    title: Text("plistNotFoundTitle", bundle: .module),
                    message: Text("plistNotFoundMessage", bundle: .module)
                )
            case .xchookWarning:
                return Alert(
                    title: Text("xchookConfirmTitle", bundle: .module),
                    message: Text("xchookConfirmMessage", bundle: .module),
                    primaryButton: .default(Text("xchookConfirmEnable", bundle: .module)) {
                        Task {
                            await store.send(.xchookInstallConfirmed)
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .xcodeRestart:
                return Alert(
                    title: Text("xcodeRestartTitle", bundle: .module),
                    message: Text("xcodeRestartMessage", bundle: .module),
                    primaryButton: .default(Text("xcodeRestartNow", bundle: .module)) {
                        Task {
                            await store.send(.xcodeRestartConfirmed)
                        }
                    },
                    secondaryButton: .cancel(Text("xcodeRestartLater", bundle: .module))
                )
            case .operationFailed:
                return Alert(
                    title: Text("operationFailedTitle", bundle: .module),
                    message: Text("operationFailedMessage", bundle: .module)
                )
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

extension GeneralSettings: ObservableObject {}
