//
//  AppViewModel.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Combine
import Foundation
import OSLog
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var notes: [StickyNote] = []
    @Published private(set) var lastPersistenceErrorDescription: String?

    private let persistence: StickyNotesPersistence
    private let autosaveDelay: TimeInterval
    private weak var windowManager: NoteWindowManaging?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.codex.AwesomeStickies",
        category: "Persistence"
    )
    private var hasBootstrapped = false
    private var autosaveWorkItem: DispatchWorkItem?

    init(
        persistence: StickyNotesPersistence,
        autosaveDelay: TimeInterval = 0.45
    ) {
        self.persistence = persistence
        self.autosaveDelay = autosaveDelay
    }

    func attachWindowManager(_ windowManager: NoteWindowManaging) {
        self.windowManager = windowManager
    }

    func bootstrapNotes() {
        guard !hasBootstrapped else {
            return
        }

        hasBootstrapped = true

        do {
            let restoredNotes = try persistence.loadNotes()

            if restoredNotes.isEmpty {
                createAndOpenNote()
                persistNotesNow()
                return
            }

            notes = restoredNotes
            restoreWindows(for: restoredNotes)
            clearPersistenceError()
        } catch {
            handlePersistenceError(error, context: "Failed to load notes during launch")
            createAndOpenNote()
            persistNotesNow()
        }
    }

    func createAndOpenNote() {
        let note = StickyNote.newNote(cascadeIndex: notes.count)
        notes.append(note)
        windowManager?.showWindow(for: note)
        scheduleAutosave()
    }

    func deleteNote(noteID: UUID) {
        guard note(withID: noteID) != nil else {
            return
        }

        let didCloseWindow = windowManager?.closeWindow(for: noteID) ?? false

        if !didCloseWindow {
            removeNote(noteID: noteID)
        }
    }

    func note(withID noteID: UUID) -> StickyNote? {
        notes.first(where: { $0.id == noteID })
    }

    func textBinding(for noteID: UUID) -> Binding<String> {
        Binding(
            get: { [weak self] in
                self?.note(withID: noteID)?.text ?? ""
            },
            set: { [weak self] newText in
                self?.updateNoteText(noteID: noteID, text: newText)
            }
        )
    }

    func colorBinding(for noteID: UUID) -> Binding<NoteColor> {
        Binding(
            get: { [weak self] in
                self?.note(withID: noteID)?.color ?? .yellow
            },
            set: { [weak self] newColor in
                self?.updateNoteColor(noteID: noteID, color: newColor)
            }
        )
    }

    func handleWindowClose(for noteID: UUID) {
        removeNote(noteID: noteID)
    }

    func updateNoteFrame(noteID: UUID, frame: NoteFrame) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteID }) else {
            return
        }

        let sanitizedFrame = frame.sanitized(minimumSize: WindowSceneConfiguration.minimumSize)

        guard notes[noteIndex].frame != sanitizedFrame else {
            return
        }

        notes[noteIndex].frame = sanitizedFrame
        notes[noteIndex].updatedAt = Date()
        scheduleAutosave()
    }

    func persistNotesNow() {
        autosaveWorkItem?.cancel()
        autosaveWorkItem = nil
        saveNotes()
    }

    private func updateNoteText(noteID: UUID, text: String) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteID }) else {
            return
        }

        notes[noteIndex].text = text
        notes[noteIndex].updatedAt = Date()
        windowManager?.updateWindow(for: notes[noteIndex])
        scheduleAutosave()
    }

    private func updateNoteColor(noteID: UUID, color: NoteColor) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteID }) else {
            return
        }

        guard notes[noteIndex].color != color else {
            return
        }

        notes[noteIndex].color = color
        notes[noteIndex].updatedAt = Date()
        windowManager?.updateWindow(for: notes[noteIndex])
        scheduleAutosave()
    }

    private func restoreWindows(for notes: [StickyNote]) {
        notes.forEach { note in
            windowManager?.showWindow(for: note)
        }
    }

    private func removeNote(noteID: UUID) {
        let originalCount = notes.count
        notes.removeAll { $0.id == noteID }

        guard notes.count != originalCount else {
            return
        }

        scheduleAutosave()
    }

    private func scheduleAutosave() {
        autosaveWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.saveNotes()
        }

        autosaveWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + autosaveDelay,
            execute: workItem
        )
    }

    private func saveNotes() {
        do {
            try persistence.saveNotes(notes)
            clearPersistenceError()
        } catch {
            handlePersistenceError(error, context: "Failed to save notes")
        }
    }

    private func clearPersistenceError() {
        lastPersistenceErrorDescription = nil
    }

    private func handlePersistenceError(_ error: Error, context: String) {
        logger.error("\(context, privacy: .public): \(error.localizedDescription, privacy: .public)")
        lastPersistenceErrorDescription = error.localizedDescription
    }
}
