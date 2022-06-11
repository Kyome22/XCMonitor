//
//  GeneralPane.swift
//  XCMonitor
//
//  Created by Takuto Nakamura on 2022/05/01.
//

import Cocoa
import Combine

final class GeneralPaneVC: NSViewController {
    @IBOutlet weak var xchookCheckBox: NSButton!
    @IBOutlet weak var launchCheckBox: NSButton!

    var originalSize = CGSize.zero
    private let model = GeneralPaneModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        originalSize = self.view.frame.size

        model.xchookCheckBoxStatePublisher
            .sink(receiveValue: { [weak self] stateBool in
                self?.xchookCheckBox.state = stateBool.state
            })
            .store(in: &cancellables)

        model.alertPublisher
            .sink(receiveValue: { [weak self] alertType in
                self?.showAlert(alertType: alertType)
            })
            .store(in: &cancellables)

        model.launchCheckBoxStatePublisher
            .sink(receiveValue: { [weak self] stateBool in
                self?.launchCheckBox.state = stateBool.state
            })
            .store(in: &cancellables)
    }

    @IBAction func toggleEnableXCHook(_ sender: NSButton) {
        model.toggleEnableXCHook(state: sender.state.isOn)
    }

    func showAlert(alertType: AlertType) {
        if alertType == .xchookWarning {
            Alert.show(alertType: alertType, window: self.view.window) { [weak self] userResponse in
                self?.model.react(for: userResponse)
            }
        } else {
            Alert.show(alertType: alertType, window: self.view.window)
        }
    }

    @IBAction func toggleLaunchAppAtLogin(_ sender: NSButton) {
        model.toggleLaunchAppAtLogin(state: sender.state.isOn)
    }
}
