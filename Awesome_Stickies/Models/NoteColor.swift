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

    var accentColor: Color {
        switch self {
        case .yellow:
            return Color(red: 0.96, green: 0.86, blue: 0.35)
        case .blue:
            return Color(red: 0.42, green: 0.70, blue: 0.95)
        case .green:
            return Color(red: 0.53, green: 0.82, blue: 0.54)
        case .pink:
            return Color(red: 0.95, green: 0.58, blue: 0.75)
        case .purple:
            return Color(red: 0.69, green: 0.58, blue: 0.93)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .yellow:
            return Color(red: 0.99, green: 0.95, blue: 0.72)
        case .blue:
            return Color(red: 0.83, green: 0.92, blue: 0.98)
        case .green:
            return Color(red: 0.84, green: 0.95, blue: 0.84)
        case .pink:
            return Color(red: 0.98, green: 0.88, blue: 0.92)
        case .purple:
            return Color(red: 0.90, green: 0.87, blue: 0.98)
        }
    }
}
