/*
 MainMenuView.swift
 UserInterface

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import DataSource
import Model
import SwiftUI

struct MainMenuView: View {
    @Environment(\.sendIntoWormhole) private var sendIntoWormhole
    @StateObject var store: MainMenu

    var body: some View {
        Button {
            Task {
                await store.send(.openProjectButtonTapped(.init(action: {
                    sendIntoWormhole(id: $0, value: $1)
                })))
            }
        } label: {
            if store.currentEvent.project.isEmpty {
                Text("noProject", bundle: .module)
            } else {
                Text("showProject\(store.currentEvent.project)", bundle: .module)
            }
        }
        .disabled(store.currentEvent.path.isEmpty)
        Menu {
            if store.eventHistories.isEmpty {
                Button {
                } label: {
                    Text("empty", bundle: .module)
                }
                .disabled(true)
            } else {
                ForEach(store.eventHistories, id: \.self) { eventHistory in
                    Button {
                        Task {
                            await store.send(.historyButtonTapped(eventHistory, .init(action: {
                                sendIntoWormhole(id: $0, value: $1)
                            })))
                        }
                    } label: {
                        Image(eventHistory.eventType.imageName, bundle: .module)
                        Text(verbatim: eventHistory.menuTitle)
                    }
                }
            }
        } label: {
            Text("eventHistory", bundle: .module)
        }
        Divider()
        SettingsLink {
            Text("settings", bundle: .module)
        }
        .buttonStyle(.preAction {
            await store.send(.settingsLinkPreActionTriggered)
        })
        Divider()
        Button {
            Task {
                await store.send(.aboutButtonTapped)
            }
        } label: {
            Text("aboutApp", bundle: .module)
        }
        Button {
            Task {
                await store.send(.quitButtonTapped)
            }
        } label: {
            Text("quitApp", bundle: .module)
        }
    }
}

extension MainMenu: ObservableObject {}
