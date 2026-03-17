//
//  Awesome_StickiesApp.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
//

import SwiftUI

@main
struct Awesome_StickiesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let container = AppContainer.shared

    var body: some Scene {
        Settings {
            SettingsView(viewModel: container.appViewModel)
        }
        .commands {
            NewNoteCommands(viewModel: container.appViewModel)
        }
    }
}
