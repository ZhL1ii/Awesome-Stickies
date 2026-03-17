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

    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

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

    var cgRect: CGRect {
        CGRect(origin: origin, size: size)
    }

    func sanitized(minimumSize: CGSize) -> NoteFrame {
        NoteFrame(
            x: x,
            y: y,
            width: max(width, minimumSize.width),
            height: max(height, minimumSize.height)
        )
    }

    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }
}
