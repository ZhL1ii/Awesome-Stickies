//
//  NoteWindowContentView.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

struct NoteWindowContentView: View {
    @ObservedObject var viewModel: AppViewModel
    let noteID: UUID

    var body: some View {
        Group {
            if let note = viewModel.note(withID: noteID) {
                StickyNoteView(
                    note: note,
                    title: viewModel.titleBinding(for: noteID),
                    text: viewModel.textBinding(for: noteID),
                    color: viewModel.colorBinding(for: noteID),
                    onCommitTitle: {
                        viewModel.commitTitleEditing(for: noteID)
                    },
                    onDelete: {
                        viewModel.deleteNote(noteID: noteID)
                    }
                )
            } else {
                Color.clear
            }
        }
        // Expand the note into the entire content area, including the transparent title bar.
        .frame(
            minWidth: WindowSceneConfiguration.minimumSize.width,
            maxWidth: .infinity,
            minHeight: WindowSceneConfiguration.minimumSize.height,
            maxHeight: .infinity
        )
        .background(.clear)
        .ignoresSafeArea()
    }
}
