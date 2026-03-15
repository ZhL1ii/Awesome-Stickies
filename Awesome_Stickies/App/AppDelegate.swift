//
//  AppDelegate.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppContainer.shared.appViewModel.bootstrapNotes()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppContainer.shared.appViewModel.persistNotesNow()
    }
}
