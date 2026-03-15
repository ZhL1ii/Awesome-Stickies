//
//  StickyNoteView.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

struct StickyNoteView: View {
    let note: StickyNote
    @Binding var text: String

    @FocusState private var isEditorFocused: Bool

    var body: some View {
        ZStack {
            note.color.backgroundColor
                .overlay {
                    Rectangle()
                        .fill(.regularMaterial.opacity(0.3))
                }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(.primary.opacity(0.75))

                    Spacer()

                    Circle()
                        .fill(note.color.accentColor.opacity(0.9))
                        .frame(width: 10, height: 10)
                }

                TextEditor(
                    text: $text
                )
                .focused($isEditorFocused)
                .scrollContentBackground(.hidden)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.thinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
                .onTapGesture {
                    isEditorFocused = true
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        }
        .padding(14)
        .frame(
            minWidth: WindowSceneConfiguration.minimumSize.width,
            minHeight: WindowSceneConfiguration.minimumSize.height
        )
        .background(.clear)
        .onAppear {
            isEditorFocused = true
        }
    }
}
