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

    @Test func deletingNoteClosesWindowRemovesMatchingNoteAndPersists() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.createAndOpenNote()
        viewModel.createAndOpenNote()

        let deletedNoteID = try #require(viewModel.notes.first?.id)
        let remainingNoteID = try #require(viewModel.notes.last?.id)

        viewModel.deleteNote(noteID: deletedNoteID)
        viewModel.handleWindowClose(for: deletedNoteID)

        #expect(windowManager.closedNoteIDs == [deletedNoteID])
        #expect(viewModel.notes.map(\.id) == [remainingNoteID])

        try await Task.sleep(for: .milliseconds(40))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].map(\.id) == [remainingNoteID])
    }

    @Test func deletingLastNoteLeavesEmptyStateUntilNextLaunch() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let windowManager = NoteWindowManagerSpy()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.01)

        viewModel.attachWindowManager(windowManager)
        viewModel.createAndOpenNote()

        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.deleteNote(noteID: noteID)
        viewModel.handleWindowClose(for: noteID)

        #expect(viewModel.notes.isEmpty)

        try await Task.sleep(for: .milliseconds(40))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].isEmpty)
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

    @Test func updatingTitleDebouncesAutosaveAndPersistsLatestTitle() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 0.02)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.titleBinding(for: noteID).wrappedValue = "A"
        viewModel.titleBinding(for: noteID).wrappedValue = "AB"
        viewModel.titleBinding(for: noteID).wrappedValue = "ABC"

        try await Task.sleep(for: .milliseconds(80))

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].first?.title == "ABC")
    }

    @Test func committingTitleEditingPersistsImmediately() async throws {
        let persistence = InMemoryStickyNotesPersistence()
        let viewModel = AppViewModel(persistence: persistence, autosaveDelay: 1)

        viewModel.createAndOpenNote()
        let noteID = try #require(viewModel.notes.first?.id)

        viewModel.titleBinding(for: noteID).wrappedValue = "Renamed"
        viewModel.commitTitleEditing(for: noteID)

        #expect(persistence.savedSnapshots.count == 1)
        #expect(persistence.savedSnapshots[0].first?.title == "Renamed")
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

    @Test func jsonPersistenceFallsBackToBackupWhenPrimaryFileIsCorrupted() async throws {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryDirectory) }

        let pathProvider = ApplicationSupportPathProvider(
            fileManager: fileManager,
            bundleIdentifier: "Awesome_StickiesTests",
            baseDirectoryURL: temporaryDirectory
        )
        let persistence = JSONStickyNotesPersistence(
            fileManager: fileManager,
            pathProvider: pathProvider
        )
        let expectedNotes = [
            StickyNote(title: "Recovered", text: "From backup", color: .green)
        ]
        let primaryURL = try pathProvider.notesFileURL
        let backupURL = try pathProvider.backupNotesFileURL

        try Data("not-json".utf8).write(to: primaryURL, options: .atomic)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(expectedNotes).write(to: backupURL, options: .atomic)

        let loadedNotes = try persistence.loadNotes()

        #expect(loadedNotes == expectedNotes)

        let repairedPrimaryData = try Data(contentsOf: primaryURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        #expect(try decoder.decode([StickyNote].self, from: repairedPrimaryData) == expectedNotes)
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
    private(set) var closedNoteIDs: [UUID] = []

    func showWindow(for note: StickyNote) {
        shownNoteIDs.append(note.id)
        shownNotes.append(note)
    }

    func closeWindow(for noteID: UUID) -> Bool {
        closedNoteIDs.append(noteID)
        return true
    }

    func updateWindow(for note: StickyNote) {}
}
