//
//  AppContainer.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Foundation

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let appViewModel: AppViewModel
    let noteWindowManager: NoteWindowManager

    private init() {
        let appViewModel = AppViewModel(
            persistence: JSONStickyNotesPersistence()
        )
        let noteWindowManager = NoteWindowManager()

        self.appViewModel = appViewModel
        self.noteWindowManager = noteWindowManager

        appViewModel.attachWindowManager(noteWindowManager)
        noteWindowManager.attachViewModel(appViewModel)
    }
}
