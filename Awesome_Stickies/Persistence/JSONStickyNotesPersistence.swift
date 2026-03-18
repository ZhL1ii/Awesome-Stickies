//
//  JSONStickyNotesPersistence.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
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

    func loadState() throws -> PersistedAppState {
        let fileURL = try pathProvider.notesFileURL
        let backupFileURL = try pathProvider.backupNotesFileURL

        guard fileManager.fileExists(atPath: fileURL.path) else {
            guard fileManager.fileExists(atPath: backupFileURL.path) else {
                return PersistedAppState()
            }

            return try loadState(from: backupFileURL)
        }

        do {
            return try loadState(from: fileURL)
        } catch {
            let primaryError = error

            guard fileManager.fileExists(atPath: backupFileURL.path) else {
                throw StickyNotesPersistenceError.loadFailed(primaryError: primaryError, backupError: nil)
            }

            do {
                let restoredState = try loadState(from: backupFileURL)
                try? copyItem(at: backupFileURL, to: fileURL)
                return restoredState
            } catch {
                throw StickyNotesPersistenceError.loadFailed(primaryError: primaryError, backupError: error)
            }
        }
    }

    func saveState(_ state: PersistedAppState) throws {
        let fileURL = try pathProvider.notesFileURL
        let backupFileURL = try pathProvider.backupNotesFileURL
        let data = try encoder.encode(state)

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            let primaryError = error

            do {
                try data.write(to: backupFileURL, options: .atomic)
                return
            } catch {
                throw StickyNotesPersistenceError.saveFailed(primaryError: primaryError, backupError: error)
            }
        }

        try? data.write(to: backupFileURL, options: .atomic)
    }

    private func loadState(from fileURL: URL) throws -> PersistedAppState {
        let data = try Data(contentsOf: fileURL)

        // Support the previous on-disk format where the file was just `[StickyNote]`.
        if let legacyNotes = try? decoder.decode([StickyNote].self, from: data) {
            return PersistedAppState(notes: legacyNotes)
        }

        let state = try decoder.decode(PersistedAppState.self, from: data)
        return PersistedAppState(
            preferences: AppPreferences(windowOpacity: state.preferences.windowOpacity),
            notes: state.notes
        )
    }

    private func copyItem(at sourceURL: URL, to destinationURL: URL) throws {
        let data = try Data(contentsOf: sourceURL)
        try data.write(to: destinationURL, options: .atomic)
    }
}

private enum StickyNotesPersistenceError: LocalizedError {
    case loadFailed(primaryError: Error, backupError: Error?)
    case saveFailed(primaryError: Error, backupError: Error)

    var errorDescription: String? {
        switch self {
        case let .loadFailed(primaryError, backupError):
            if let backupError {
                return "Failed to load notes from both primary and backup files: \(primaryError.localizedDescription); backup: \(backupError.localizedDescription)"
            }

            return "Failed to load notes: \(primaryError.localizedDescription)"
        case let .saveFailed(primaryError, backupError):
            return "Failed to save notes to both primary and backup files: \(primaryError.localizedDescription); backup: \(backupError.localizedDescription)"
        }
    }
}
