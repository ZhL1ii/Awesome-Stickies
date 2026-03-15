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
                    text: viewModel.textBinding(for: noteID)
                )
            } else {
                Color.clear
            }
        }
        .frame(
            minWidth: WindowSceneConfiguration.minimumSize.width,
            minHeight: WindowSceneConfiguration.minimumSize.height
        )
    }
}
