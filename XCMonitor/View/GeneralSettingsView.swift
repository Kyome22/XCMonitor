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
                    .onChange(of: viewModel.xchookEnabled) { newValue in
                        viewModel.toggleXCHookEnabled(newValue)
                    }
                    Toggle(isOn: $viewModel.launchAtLogin) {
                        Text("launchAtLogin")
                    }
                    .onChange(of: viewModel.launchAtLogin) { newValue in
                        viewModel.toggleLaunchAtLogin(newValue)
                    }
                }
            }
        }
        .padding(20)
        .alert(isPresented: $viewModel.showingAlert) {
            switch viewModel.alertType {
            case .xcodePlistNotFound:
                return Alert(title: Text("plistNotFoundTitle"),
                             message: Text("plistNotFoundMessage"))
            case .xcodeIsRunning:
                return Alert(title: Text("xcodeIsRunningTitle"),
                             message: Text("xcodeIsRunningMessage"))
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
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
