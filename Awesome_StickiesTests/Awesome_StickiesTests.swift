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
            StickyNote(title: "First", text: "A"),
            StickyNote(title: "Second", text: "B")
        ]
        let persistence = InMemoryStickyNotesPersistence(loadedNotes: restoredNotes)
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.bootstrapNotes()

        #expect(viewModel.notes == restoredNotes)
        #expect(windowManager.shownNoteIDs == restoredNotes.map(\.id))
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

    func showWindow(for note: StickyNote) {
        shownNoteIDs.append(note.id)
    }

    func closeWindow(for noteID: UUID) {}

    func updateWindow(for note: StickyNote) {}
}
