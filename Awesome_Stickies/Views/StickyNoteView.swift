//
//  StickyNoteView.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
//

import SwiftUI

struct StickyNoteView: View {
    private enum ActiveField {
        case title
        case body
    }

    private enum ToolbarControl: Hashable {
        case color
        case delete
    }

    @Binding var title: String
    @Binding var text: String
    @Binding var color: NoteColor
    let onCommitTitle: () -> Void
    let onDelete: () -> Void

    @FocusState private var isEditorFocused: Bool
    @FocusState private var isTitleEditorFocused: Bool
    @State private var isShowingDeleteConfirmation = false
    @State private var titleFieldWidth: CGFloat = 80
    @State private var lastFocusedField: ActiveField = .body
    @State private var hoveredToolbarControl: ToolbarControl?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Keep the note as a single glass sheet: material first, then a tinted wash,
            // then a restrained highlight so the surface feels lighter without growing heavy.
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.glassTintColor.opacity(0.58),
                                    color.glassTintColor.opacity(0.34)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(color.glassGlowColor)
                        .frame(width: 190, height: 190)
                        .offset(x: 44, y: 72)
                        .blur(radius: 28)
                        .allowsHitTesting(false)
                }

            VStack(alignment: .leading, spacing: 8) {
                header

                // The editor stays visually attached to the main glass plate.
                // A light inner wash improves readability without creating another card.
                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 16))
                    .foregroundStyle(color.bodyColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    .padding(.bottom, 10)
                    .background(alignment: .top) {
                        // The editor still gets a readability wash, but its edges stay quiet
                        // so it feels etched into the same glass surface instead of a second card.
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.07),
                                        color.editorBackgroundColor.opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.20),
                                                color.borderColor.opacity(0.32),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 0.8
                                    )
                            }
                            .padding(.horizontal, 1)
                            .allowsHitTesting(false)
                    }
                    .onTapGesture {
                        isEditorFocused = true
                    }
                    .onChange(of: isEditorFocused) { _, isFocused in
                        if isFocused {
                            lastFocusedField = .body
                        }
                    }
            }
            .padding(.top, 12)
            .padding(.leading, 18)
            .padding(.trailing, 18)
            .padding(.bottom, 18)
        }
        // The sticky itself is the visible window chrome.
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            color.glassEdgeColor,
                            color.borderColor.opacity(0.9),
                            color.accentColor.opacity(0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .inset(by: 1)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.6)
        }
        .frame(
            minWidth: WindowSceneConfiguration.minimumSize.width,
            maxWidth: .infinity,
            minHeight: WindowSceneConfiguration.minimumSize.height,
            maxHeight: .infinity
        )
        .background(.clear)
        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
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
}

private extension StickyNoteView {
    var header: some View {
        HStack(spacing: 10) {
            titleField

            Spacer(minLength: 0)

            toolbarControls
        }
        .padding(.horizontal, 8)
        .padding(.top, 3)
        .padding(.bottom, 2)
    }

    var titleWidthReference: String {
        title.isEmpty ? StickyNote.defaultTitle : title
    }

    var titleField: some View {
        TextField(StickyNote.defaultTitle, text: $title)
            .textFieldStyle(.plain)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(color.titleColor)
            .submitLabel(.done)
            .frame(width: titleFieldWidth, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .focused($isTitleEditorFocused)
            .onSubmit {
                onCommitTitle()
            }
            .onChange(of: isTitleEditorFocused) { _, isFocused in
                if isFocused {
                    lastFocusedField = .title
                }

                if !isFocused {
                    onCommitTitle()
                }
            }
            .background(alignment: .leading) {
                Text(titleWidthReference)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                    .fixedSize()
                    .opacity(0)
                    .allowsHitTesting(false)
                    .readWidth { width in
                        titleFieldWidth = min(max(width + 4, 80), 200)
                    }
            }
    }

    var toolbarControls: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(NoteColor.allCases) { option in
                    Button {
                        color = option
                        restoreFocusAfterColorChange()
                    } label: {
                        Label(option.displayName, systemImage: option == color ? "checkmark.circle.fill" : "circle")
                    }
                }
            } label: {
                toolbarIconLabel(
                    systemImage: "paintpalette",
                    foregroundColor: toolbarForegroundColor(for: .color),
                    isHovered: hoveredToolbarControl == .color
                )
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
            .help("Change note color")
            .onHover { isHovered in
                hoveredToolbarControl = isHovered ? .color : clearedHoverState(for: .color)
            }

            Button {
                isShowingDeleteConfirmation = true
            } label: {
                toolbarIconLabel(
                    systemImage: "trash",
                    foregroundColor: toolbarForegroundColor(for: .delete),
                    isHovered: hoveredToolbarControl == .delete
                )
            }
            .buttonStyle(.plain)
            .help("Delete note")
            .onHover { isHovered in
                hoveredToolbarControl = isHovered ? .delete : clearedHoverState(for: .delete)
            }
        }
    }

    @ViewBuilder
    func toolbarIconLabel(systemImage: String, foregroundColor: Color, isHovered: Bool) -> some View {
        Label(systemImage, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(foregroundColor.opacity(isHovered ? 1.0 : 0.88))
            .frame(width: 22, height: 22)
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.14), value: isHovered)
    }

    private func clearedHoverState(for control: ToolbarControl) -> ToolbarControl? {
        hoveredToolbarControl == control ? nil : hoveredToolbarControl
    }

    private func toolbarForegroundColor(for control: ToolbarControl) -> Color {
        switch control {
        case .color:
            return colorScheme == .dark
                ? Color(nsColor: .white).opacity(0.92)
                : Color(nsColor: .labelColor).opacity(0.82)
        case .delete:
            return colorScheme == .dark
                ? Color(nsColor: .white).opacity(0.92)
                : Color(nsColor: .labelColor).opacity(0.82)
        }
    }

    func restoreFocusAfterColorChange() {
        DispatchQueue.main.async {
            switch lastFocusedField {
            case .title:
                isTitleEditorFocused = true
            case .body:
                isEditorFocused = true
            }
        }
    }
}

private struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    func readWidth(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(WidthPreferenceKey.self, perform: onChange)
    }
}
