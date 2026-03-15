//
//  NewNoteCommands.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

struct NewNoteCommands: Commands {
    let viewModel: AppViewModel

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Note") {
                viewModel.createAndOpenNote()
            }
            .keyboardShortcut("n")
        }
    }
}
