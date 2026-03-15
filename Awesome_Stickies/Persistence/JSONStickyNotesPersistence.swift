//
//  JSONStickyNotesPersistence.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Foundation

final class JSONStickyNotesPersistence: StickyNotesPersistence {
    private let fileManager: FileManager
    private let pathProvider: ApplicationSupportPathProvider
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        pathProvider: ApplicationSupportPathProvider = ApplicationSupportPathProvider()
    ) {
        self.fileManager = fileManager
        self.pathProvider = pathProvider

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadNotes() throws -> [StickyNote] {
        let fileURL = try pathProvider.notesFileURL
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([StickyNote].self, from: data)
    }

    func saveNotes(_ notes: [StickyNote]) throws {
        let fileURL = try pathProvider.notesFileURL
        let data = try encoder.encode(notes)
        try data.write(to: fileURL, options: .atomic)
    }
}
