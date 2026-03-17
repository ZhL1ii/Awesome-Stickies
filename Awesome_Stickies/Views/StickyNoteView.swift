//
//  StickyNoteView.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

struct StickyNoteView: View {
    let note: StickyNote
    @Binding var title: String
    @Binding var text: String
    @Binding var color: NoteColor
    let onCommitTitle: () -> Void
    let onDelete: () -> Void

    @FocusState private var isEditorFocused: Bool
    @FocusState private var isTitleEditorFocused: Bool
    @State private var isEditingTitle = false
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        ZStack {
            color.backgroundColor
                .overlay {
                    Rectangle()
                        .fill(.regularMaterial.opacity(0.3))
                }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        if isEditingTitle {
                            TextField("Note Title", text: $title)
                                .textFieldStyle(.plain)
                                .font(.headline)
                                .foregroundStyle(color.titleColor)
                                .submitLabel(.done)
                                .focused($isTitleEditorFocused)
                                .onSubmit {
                                    finishTitleEditing()
                                }
                                .onChange(of: isTitleEditorFocused) { _, isFocused in
                                    if !isFocused {
                                        finishTitleEditing()
                                    }
                                }
                        } else {
                            Text(note.title)
                                .font(.headline)
                                .foregroundStyle(color.titleColor)
                                .lineLimit(1)
                                .onTapGesture(count: 2) {
                                    startTitleEditing()
                                }
                        }
                    }

                    Spacer()

                    Menu {
                        ForEach(NoteColor.allCases) { option in
                            Button {
                                color = option
                            } label: {
                                Label(option.displayName, systemImage: option == color ? "checkmark.circle.fill" : "circle")
                            }
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

                    Button {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
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
                    .buttonStyle(.plain)
                    .help("Delete note")
                }

                TextEditor(
                    text: $text
                )
                .focused($isEditorFocused)
                .scrollContentBackground(.hidden)
                .font(.system(size: 16))
                .foregroundStyle(color.bodyColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
        // The sticky itself is the visible window chrome.
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(color.borderColor, lineWidth: 1)
        }
        .frame(
            minWidth: WindowSceneConfiguration.minimumSize.width,
            maxWidth: .infinity,
            minHeight: WindowSceneConfiguration.minimumSize.height,
            maxHeight: .infinity
        )
        .background(.clear)
        .onAppear {
            isEditorFocused = true
        }
        .alert("Delete this note?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func startTitleEditing() {
        isEditingTitle = true
        isTitleEditorFocused = true
    }

    private func finishTitleEditing() {
        guard isEditingTitle else {
            return
        }

        isEditingTitle = false
        isTitleEditorFocused = false
        onCommitTitle()
    }
}
