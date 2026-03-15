//
//  StickyNotesPersistence.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Foundation

protocol StickyNotesPersistence {
    func loadNotes() throws -> [StickyNote]
    func saveNotes(_ notes: [StickyNote]) throws
}
