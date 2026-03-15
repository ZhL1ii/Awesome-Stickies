//
//  ApplicationSupportPathProvider.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Foundation

struct ApplicationSupportPathProvider {
    let fileManager: FileManager
    let bundleIdentifier: String

    init(
        fileManager: FileManager = .default,
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.codex.AwesomeStickies"
    ) {
        self.fileManager = fileManager
        self.bundleIdentifier = bundleIdentifier
    }

    var applicationSupportDirectoryURL: URL {
        get throws {
            let baseURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directoryURL = baseURL.appendingPathComponent(bundleIdentifier, isDirectory: true)

            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            }

            return directoryURL
        }
    }

    var notesFileURL: URL {
        get throws {
            try applicationSupportDirectoryURL
                .appendingPathComponent("notes.json", isDirectory: false)
        }
    }
}
