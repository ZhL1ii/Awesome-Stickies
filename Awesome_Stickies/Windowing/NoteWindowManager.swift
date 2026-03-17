//
//  NoteWindowManager.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import AppKit
import SwiftUI

@MainActor
protocol NoteWindowManaging: AnyObject {
    func showWindow(for note: StickyNote)
    func closeWindow(for noteID: UUID) -> Bool
    func updateWindow(for note: StickyNote)
}

@MainActor
final class NoteWindowManager: NSObject, NoteWindowManaging {
    private weak var viewModel: AppViewModel?
    private var windowsByNoteID: [UUID: NSWindow] = [:]
    private var noteIDsByWindowNumber: [Int: UUID] = [:]

    func attachViewModel(_ viewModel: AppViewModel) {
        self.viewModel = viewModel
    }

    func showWindow(for note: StickyNote) {
        if let existingWindow = windowsByNoteID[note.id] {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingController = NSHostingController(
            rootView: NoteWindowContentView(
                viewModel: requiredViewModel(),
                noteID: note.id
            )
        )

        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier(note.id.uuidString)
        window.delegate = self
        window.title = note.title
        let frame = note.frame.sanitized(minimumSize: WindowSceneConfiguration.minimumSize)
        window.setFrame(frame.cgRect, display: false)
        window.minSize = WindowSceneConfiguration.minimumSize
        window.isReleasedWhenClosed = false
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(nil)

        windowsByNoteID[note.id] = window
        noteIDsByWindowNumber[window.windowNumber] = note.id
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow(for noteID: UUID) -> Bool {
        guard let window = windowsByNoteID.removeValue(forKey: noteID) else {
            return false
        }

        noteIDsByWindowNumber.removeValue(forKey: window.windowNumber)
        window.close()
        return true
    }

    func updateWindow(for note: StickyNote) {
        guard let window = windowsByNoteID[note.id] else {
            return
        }

        window.title = note.title
    }

    private func requiredViewModel() -> AppViewModel {
        guard let viewModel else {
            preconditionFailure("NoteWindowManager must be attached to AppViewModel before use.")
        }

        return viewModel
    }
}

extension NoteWindowManager: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        syncWindowFrame(notification)
    }

    func windowDidResize(_ notification: Notification) {
        syncWindowFrame(notification)
    }

    func windowWillClose(_ notification: Notification) {
        guard
            let window = notification.object as? NSWindow,
            let noteID = noteID(for: window)
        else {
            return
        }

        windowsByNoteID.removeValue(forKey: noteID)
        noteIDsByWindowNumber.removeValue(forKey: window.windowNumber)
        viewModel?.handleWindowClose(for: noteID)
    }

    private func syncWindowFrame(_ notification: Notification) {
        guard
            let window = notification.object as? NSWindow,
            let noteID = noteID(for: window)
        else {
            return
        }

        viewModel?.updateNoteFrame(noteID: noteID, frame: NoteFrame(rect: window.frame))
    }

    private func noteID(for window: NSWindow) -> UUID? {
        if let noteID = noteIDsByWindowNumber[window.windowNumber] {
            return noteID
        }

        guard
            let identifier = window.identifier?.rawValue,
            let noteID = UUID(uuidString: identifier)
        else {
            return nil
        }

        noteIDsByWindowNumber[window.windowNumber] = noteID
        return noteID
    }
}
