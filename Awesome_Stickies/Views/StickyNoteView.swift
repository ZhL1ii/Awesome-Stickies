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
    @Binding var color: NoteColor
    let onDelete: () -> Void

    @FocusState private var isEditorFocused: Bool

    var body: some View {
        ZStack {
            color.backgroundColor
                .overlay {
                    Rectangle()
                        .fill(.regularMaterial.opacity(0.3))
                }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(color.titleColor)

                    Spacer()

                    Menu {
                        ForEach(NoteColor.allCases) { option in
                            Button {
                                color = option
                            } label: {
                                Label(option.displayName, systemImage: option == color ? "checkmark.circle.fill" : "circle")
                            }
                        }

                        Divider()

                        Button(role: .destructive, action: onDelete) {
                            Label("Delete Note", systemImage: "trash")
                        }
                    } label: {
                        Label("Note Color", systemImage: "paintpalette")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(color.titleColor)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(color.editorBackgroundColor.opacity(0.95))
                            )
                            .overlay(
                                Circle()
                                    .stroke(color.accentColor.opacity(0.9), lineWidth: 2)
                            )
                    }
                    .menuStyle(.borderlessButton)
                    .help("Change note color")
                }

                TextEditor(
                    text: $text
                )
                .focused($isEditorFocused)
                .scrollContentBackground(.hidden)
                .font(.system(size: 16))
                .foregroundStyle(color.bodyColor)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(color.editorBackgroundColor)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(color.borderColor, lineWidth: 1)
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
                .strokeBorder(color.borderColor, lineWidth: 1)
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
