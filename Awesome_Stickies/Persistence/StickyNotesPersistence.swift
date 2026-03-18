//
//  StickyNotesPersistence.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
//

import Foundation

protocol StickyNotesPersistence {
    func loadState() throws -> PersistedAppState
    func saveState(_ state: PersistedAppState) throws
}

struct PersistedAppState: Codable, Equatable {
    var preferences: AppPreferences
    var notes: [StickyNote]

    init(
        preferences: AppPreferences = AppPreferences(),
        notes: [StickyNote] = []
    ) {
        self.preferences = preferences
        self.notes = notes
    }
}
