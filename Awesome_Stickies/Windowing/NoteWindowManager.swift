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
    func updateWindowOpacity(_ opacity: Double)
}

@MainActor
final class NoteWindowManager: NSObject, NoteWindowManaging {
    private weak var viewModel: AppViewModel?
    private var windowsByNoteID: [UUID: NSWindow] = [:]
    private var noteIDsByWindowNumber: [Int: UUID] = [:]
    private var currentWindowOpacity = AppPreferences.defaultWindowOpacity

    func attachViewModel(_ viewModel: AppViewModel) {
        self.viewModel = viewModel
        currentWindowOpacity = viewModel.windowOpacity
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
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier(note.id.uuidString)
        window.delegate = self
        window.title = note.title
        let frame = note.frame.sanitized(minimumSize: WindowSceneConfiguration.minimumSize)
        window.setFrame(frame.cgRect, display: false)
        window.minSize = WindowSceneConfiguration.minimumSize
        window.isReleasedWhenClosed = false
        configureAppearance(for: window)
        applyWindowOpacity(to: window)
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

    func updateWindowOpacity(_ opacity: Double) {
        currentWindowOpacity = AppPreferences.clamp(opacity)

        windowsByNoteID.values.forEach { window in
            applyWindowOpacity(to: window)
        }
    }

    private func requiredViewModel() -> AppViewModel {
        guard let viewModel else {
            preconditionFailure("NoteWindowManager must be attached to AppViewModel before use.")
        }

        return viewModel
    }

    private func configureAppearance(for window: NSWindow) {
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.isMovableByWindowBackground = true

        // Keep the titled/resizable window model, but remove the default shell
        // so the sticky content defines the visible shape.
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

        // Hide all standard title bar controls so the sticky remains the only visible chrome.
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }

    private func applyWindowOpacity(to window: NSWindow) {
        window.alphaValue = CGFloat(currentWindowOpacity)
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
