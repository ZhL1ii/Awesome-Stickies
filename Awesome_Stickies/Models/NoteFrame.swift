//
//  NoteFrame.swift
//  Awesome_Stickies
//
//  Created by Codex on 2026/3/15.
//

import Foundation
import CoreGraphics

struct NoteFrame: Codable, Equatable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    static let defaultFrame = NoteFrame(
        x: 120,
        y: 120,
        width: 280,
        height: 320
    )

    var origin: CGPoint {
        CGPoint(x: x, y: y)
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }
}
