//
//  WindowSceneConfiguration.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import SwiftUI

enum WindowSceneConfiguration {
    static let minimumSize = CGSize(width: 320, height: 360)
    static let defaultSize = CGSize(width: 320, height: 360)

    static func defaultFrame(forCascadeIndex index: Int) -> NoteFrame {
        let cappedIndex = index % 6

        return NoteFrame(
            x: 160 + Double(cappedIndex * 28),
            y: 160 + Double(cappedIndex * 28),
            width: defaultSize.width,
            height: defaultSize.height
        )
    }
}
