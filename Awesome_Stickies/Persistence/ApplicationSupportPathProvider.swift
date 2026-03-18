//
//  ApplicationSupportPathProvider.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/15.
//

import Foundation

struct ApplicationSupportPathProvider {
    let fileManager: FileManager
    let bundleIdentifier: String
    let baseDirectoryURL: URL?

    init(
        fileManager: FileManager = .default,
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.codex.AwesomeStickies",
        baseDirectoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.bundleIdentifier = bundleIdentifier
        self.baseDirectoryURL = baseDirectoryURL
    }

    var applicationSupportDirectoryURL: URL {
        get throws {
            let baseURL: URL

            if let baseDirectoryURL {
                baseURL = baseDirectoryURL
            } else {
                baseURL = try fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
            }

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

    var backupNotesFileURL: URL {
        get throws {
            try applicationSupportDirectoryURL
                .appendingPathComponent("notes.backup.json", isDirectory: false)
        }
    }
}
