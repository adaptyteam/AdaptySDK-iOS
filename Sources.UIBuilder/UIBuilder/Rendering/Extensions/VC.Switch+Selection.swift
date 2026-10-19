//
//  VC.Switch+Selection.swift
//  AdaptyUIBuilder
//

import CoreGraphics
import Foundation

extension VC.Switch {
    /// The element shown: the first case whose conditions hold, `default` when
    /// none does. `available` is what the parent offers, the screen where it
    /// offers nothing.
    func selectedContent(available: CGSize, screen: CGSize, orientation: VC.Orientation) -> VC.ElementIndex {
        cases.first {
            VC.Condition.evaluate($0.condition, available: available, screen: screen, orientation: orientation)
        }?.content ?? `default`
    }

    /// Whether any case compares `available_width` or `available_height`, and so
    /// needs to learn what the parent proposes.
    var readsAvailableSize: Bool {
        cases.contains { $0.condition.contains(where: \.readsAvailableSize) }
    }
}

extension VC.Condition {
    var readsAvailableSize: Bool {
        switch self {
        case .availableWidth, .availableHeight: true
        case .screenWidth, .screenHeight, .orientation: false
        }
    }
}
