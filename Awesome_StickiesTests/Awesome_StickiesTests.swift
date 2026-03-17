//
//  Awesome_StickiesTests.swift
//  Awesome_StickiesTests
//
//  Created by Chie on 2026/3/15.
//

import Foundation
import SwiftUI
import Testing
@testable import Awesome_Stickies

@MainActor
struct Awesome_StickiesTests {

    @Test func createAndOpenNoteAppendsNoteAndRequestsWindow() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.createAndOpenNote()

        #expect(viewModel.notes.count == 1)
        #expect(windowManager.shownNoteIDs == [viewModel.notes[0].id])
        #expect(viewModel.notes[0].frame == WindowSceneConfiguration.defaultFrame(forCascadeIndex: 0))

        try await Task.sleep(for: .milliseconds(40))
        #expect(persistence.savedSnapshots.count == 1)
    }

    @Test func closingOneWindowOnlyRemovesMatchingNote() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.createAndOpenNote()
        viewModel.createAndOpenNote()

        let firstNoteID = try #require(viewModel.notes.first?.id)
        let remainingNoteID = try #require(viewModel.notes.last?.id)

        viewModel.handleWindowClose(for: firstNoteID)

        #expect(viewModel.notes.count == 1)
        #expect(viewModel.notes[0].id == remainingNoteID)
    }

    @Test func bootstrapRestoresPersistedNotesAndReopensWindows() async throws {
        let restoredNotes = [
            StickyNote(
                title: "First",
                text: "A",
                frame: NoteFrame(x: 240, y: 300, width: 420, height: 460)
            ),
            StickyNote(
                title: "Second",
                text: "B",
                frame: NoteFrame(x: 360, y: 420, width: 380, height: 400)
            )
        ]
        let persistence = InMemoryStickyNotesPersistence(loadedNotes: restoredNotes)
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.bootstrapNotes()

        #expect(viewModel.notes == restoredNotes)
        #expect(windowManager.shownNoteIDs == restoredNotes.map(\.id))
        #expect(windowManager.shownNotes == restoredNotes)
    }

    @Test func bootstrapCreatesDefaultNoteWhenNoPersistedNotesExist() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.bootstrapNotes()

        #expect(viewModel.notes.count == 1)
        #expect(windowManager.shownNoteIDs == [viewModel.notes[0].id])
    }

    @Test func updatingTextDebouncesAutosaveToLatestSnapshot() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.02)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.textBinding(for: noteID).wrappedValue = "A"
        viewModel.textBinding(for: noteID).wrappedValue = "AB"
        viewModel.textBinding(for: noteID).wrappedValue = "ABC"

        try await Task.sleep(for: .milliseconds(80))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].first?.text == "ABC")
    }

    @Test func updatingColorDebouncesAutosaveAndPersistsLatestColor() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.02)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.colorBinding(for: noteID).wrappedValue = .blue
        viewModel.colorBinding(for: noteID).wrappedValue = .green

        #expect(viewModel.note(withID: noteID)?.color == .green)

        try await Task.sleep(for: .milliseconds(80))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].first?.color == .green)
    }

    @Test func updatingFrameDebouncesAutosaveAndPersistsLatestFrame() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.02)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.updateNoteFrame(
            noteID: noteID,
            frame: NoteFrame(x: 180, y: 220, width: 420, height: 460)
        )
        viewModel.updateNoteFrame(
            noteID: noteID,
            frame: NoteFrame(x: 210, y: 260, width: 480, height: 520)
        )

        #expect(viewModel.note(withID: noteID)?.frame == NoteFrame(x: 210, y: 260, width: 480, height: 520))

        try await Task.sleep(for: .milliseconds(80))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].first?.frame == NoteFrame(x: 210, y: 260, width: 480, height: 520))
    }

    @Test func updatingFrameClampsToWindowMinimumSize() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.updateNoteFrame(
            noteID: noteID,
            frame: NoteFrame(x: 150, y: 170, width: 100, height: 120)
        )

        #expect(
            viewModel.note(withID: noteID)?.frame ==
            NoteFrame(
                x: 150,
                y: 170,
                width: WindowSceneConfiguration.minimumSize.width,
                height: WindowSceneConfiguration.minimumSize.height
            )
        )
    }

    @Test func bootstrapRestoresPersistedNoteColor() async throws {
        let restoredNotes = [
            StickyNote(title: "Colored", text: "A", color: .purple)
        ]
        let persistence = InMemoryStickyNotesPersistence(loadedNotes: restoredNotes)
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.bootstrapNotes()

        #expect(viewModel.notes.first?.color == .purple)
    }
}

private final class InMemoryStickyNotesPersistence: StickyNotesPersistence {
    private let loadedNotes: [StickyNote]
    private(set) var savedSnapshots: [[StickyNote]] = []

    init(loadedNotes: [StickyNote] = []) {
        self.loadedNotes = loadedNotes
    }

    func loadNotes() throws -> [StickyNote] { loadedNotes }

    func saveNotes(_ notes: [StickyNote]) throws {
        savedSnapshots.append(notes)
    }
}

@MainActor
private final class NoteWindowManagerSpy: NoteWindowManaging {
    private(set) var shownNoteIDs: [UUID] = []
    private(set) var shownNotes: [StickyNote] = []

    func showWindow(for note: StickyNote) {
        shownNoteIDs.append(note.id)
        shownNotes.append(note)
    }

    func closeWindow(for noteID: UUID) {}

    func updateWindow(for note: StickyNote) {}
}
