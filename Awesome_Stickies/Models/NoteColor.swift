//
//  NoteColor.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

enum NoteColor: String, Codable, CaseIterable, Identifiable {
    case yellow
    case blue
    case green
    case pink
    case purple

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    private var palette: Palette {
        switch self {
        case .yellow:
            return Palette(
                accent: Color(red: 0.96, green: 0.86, blue: 0.35),
                background: Color(red: 0.99, green: 0.95, blue: 0.72),
                editorBackground: Color(red: 1.0, green: 0.98, blue: 0.86),
                border: Color.white.opacity(0.30),
                title: Color.black.opacity(0.72),
                body: Color.black.opacity(0.82)
            )
        case .blue:
            return Palette(
                accent: Color(red: 0.42, green: 0.70, blue: 0.95),
                background: Color(red: 0.83, green: 0.92, blue: 0.98),
                editorBackground: Color(red: 0.94, green: 0.97, blue: 1.0),
                border: Color.white.opacity(0.28),
                title: Color.black.opacity(0.72),
                body: Color.black.opacity(0.82)
            )
        case .green:
            return Palette(
                accent: Color(red: 0.53, green: 0.82, blue: 0.54),
                background: Color(red: 0.84, green: 0.95, blue: 0.84),
                editorBackground: Color(red: 0.93, green: 0.98, blue: 0.93),
                border: Color.white.opacity(0.28),
                title: Color.black.opacity(0.72),
                body: Color.black.opacity(0.82)
            )
        case .pink:
            return Palette(
                accent: Color(red: 0.95, green: 0.58, blue: 0.75),
                background: Color(red: 0.98, green: 0.88, blue: 0.92),
                editorBackground: Color(red: 1.0, green: 0.95, blue: 0.97),
                border: Color.white.opacity(0.30),
                title: Color.black.opacity(0.72),
                body: Color.black.opacity(0.82)
            )
        case .purple:
            return Palette(
                accent: Color(red: 0.69, green: 0.58, blue: 0.93),
                background: Color(red: 0.90, green: 0.87, blue: 0.98),
                editorBackground: Color(red: 0.96, green: 0.94, blue: 1.0),
                border: Color.white.opacity(0.28),
                title: Color.black.opacity(0.74),
                body: Color.black.opacity(0.84)
            )
        }
    }

    var accentColor: Color {
        palette.accent
    }

    var backgroundColor: Color {
        palette.background
    }

    var editorBackgroundColor: Color {
        palette.editorBackground
    }

    var borderColor: Color {
        palette.border
    }

    var titleColor: Color {
        palette.title
    }

    var bodyColor: Color {
        palette.body
    }

    private struct Palette {
        let accent: Color
        let background: Color
        let editorBackground: Color
        let border: Color
        let title: Color
        let body: Color
    }
}
