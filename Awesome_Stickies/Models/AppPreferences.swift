//
//  AppPreferences.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/17.
//

import Foundation

struct AppPreferences: Codable, Equatable {
    static let defaultWindowOpacity = 0.9
    static let minimumWindowOpacity = 0.72
    static let maximumWindowOpacity = 1.0

    var windowOpacity: Double

    init(windowOpacity: Double = AppPreferences.defaultWindowOpacity) {
        self.windowOpacity = AppPreferences.clamp(windowOpacity)
    }

    static func clamp(_ value: Double) -> Double {
        min(max(value, minimumWindowOpacity), maximumWindowOpacity)
    }
}
