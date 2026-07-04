//
//  GeneralSettingsView.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/06/11.
//

import SwiftUI

struct GeneralSettingsView: View {
    @StateObject var viewModel = GeneralSettingsViewModel()

    var body: some View {
        Form {
            HStack {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("XCHook:")
                    Text("startup:")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $viewModel.xchookEnabled) {
                        Text("enableScripts")
                    }
                    .disabled(viewModel.showingAlert)
                    .onChange(of: viewModel.xchookEnabled) { _, newValue in
                        viewModel.toggleXCHookEnabled(newValue)
                    }
                    Toggle(isOn: $viewModel.launchAtLogin) {
                        Text("launchAtLogin")
                    }
                    .onChange(of: viewModel.launchAtLogin) { _, newValue in
                        viewModel.toggleLaunchAtLogin(newValue)
                    }
                }
            }
        }
        .fixedSize()
        .padding(20)
        .alert(isPresented: $viewModel.showingAlert) {
            switch viewModel.alertType {
            case .xcodePlistNotFound:
                return Alert(title: Text("plistNotFoundTitle"),
                             message: Text("plistNotFoundMessage"))
            case .xchookWarning:
                let enableButton = Alert.Button.default(Text("xchookConfirmEnable")) {
                    viewModel.react(for: true)
                }
                let cancelButton = Alert.Button.cancel {
                    viewModel.react(for: false)
                }
                return Alert(title: Text("xchookConfirmTitle"),
                             message: Text("xchookConfirmMessage"),
                             primaryButton: enableButton,
                             secondaryButton: cancelButton)
            case .xcodeRestart:
                let restartButton = Alert.Button.default(Text("xcodeRestartNow")) {
                    viewModel.restartXcode()
                }
                let laterButton = Alert.Button.cancel(Text("xcodeRestartLater"))
                return Alert(title: Text("xcodeRestartTitle"),
                             message: Text("xcodeRestartMessage"),
                             primaryButton: restartButton,
                             secondaryButton: laterButton)
            case .operationFailed:
                return Alert(title: Text("operationFailedTitle"),
                             message: Text("operationFailedMessage"))
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
