/*
 ErrorAlertScene.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/05.
 
 */

import Model
import SwiftUI
import WormholeKit

public struct ErrorAlertScene: Scene {
    @WormholeState(id: .errorAlert) private var showingAlert = false

    public init() {}

    public var body: some Scene {
        AlertScene(
            Text("projectNotOpenTitle", bundle: .module),
            isPresented: $showingAlert,
            actions: {},
            message: {
                Text("projectNotOpenMessage", bundle: .module)
            }
        )
    }
}
