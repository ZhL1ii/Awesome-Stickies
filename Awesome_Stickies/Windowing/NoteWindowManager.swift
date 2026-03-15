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
    func closeWindow(for noteID: UUID)
    func updateWindow(for note: StickyNote)
}

@MainActor
final class NoteWindowManager: NSObject, NoteWindowManaging {
    private weak var viewModel: AppViewModel?
    private var windowsByNoteID: [UUID: NSWindow] = [:]

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
        window.setContentSize(note.frame.size)
        window.setFrameOrigin(note.frame.origin)
        window.minSize = WindowSceneConfiguration.minimumSize
        window.isReleasedWhenClosed = false
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.centerIfNeeded()
        window.makeKeyAndOrderFront(nil)

        windowsByNoteID[note.id] = window
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow(for noteID: UUID) {
        guard let window = windowsByNoteID.removeValue(forKey: noteID) else {
            return
        }

        window.delegate = nil
        window.close()
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
    func windowWillClose(_ notification: Notification) {
        guard
            let window = notification.object as? NSWindow,
            let identifier = window.identifier?.rawValue,
            let noteID = UUID(uuidString: identifier)
        else {
            return
        }

        windowsByNoteID.removeValue(forKey: noteID)
        viewModel?.handleWindowClose(for: noteID)
    }
}

private extension NSWindow {
    func centerIfNeeded() {
        guard frame.origin == .zero else {
            return
        }

        center()
    }
}
