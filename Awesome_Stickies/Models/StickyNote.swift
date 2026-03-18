//
//  StickyNote.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
//

import Foundation

struct StickyNote: Identifiable, Codable, Equatable {
    static let defaultTitle = "Untitled"

    let id: UUID
    var title: String
    var text: String
    var color: NoteColor
    var frame: NoteFrame
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = StickyNote.defaultTitle,
        text: String = "",
        color: NoteColor = .yellow,
        frame: NoteFrame = .defaultFrame,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.color = color
        self.frame = frame
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func newNote(cascadeIndex: Int) -> StickyNote {
        StickyNote(
            title: StickyNote.defaultTitle,
            color: .yellow,
            frame: WindowSceneConfiguration.defaultFrame(forCascadeIndex: cascadeIndex)
        )
    }
}
