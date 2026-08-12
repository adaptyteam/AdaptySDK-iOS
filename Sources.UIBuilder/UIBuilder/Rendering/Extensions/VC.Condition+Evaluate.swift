//
//  VC.Condition+Evaluate.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import CoreGraphics
import Foundation

extension VC.Orientation: Equatable {}

extension VC.Condition {
    /// Logical AND over all conditions. An empty array → `true`.
    static func evaluate(
        _ conditions: [VC.Condition],
        available: CGSize,
        screen: CGSize,
        orientation: VC.Orientation
    ) -> Bool {
        for condition in conditions {
            guard condition.matches(available: available, screen: screen, orientation: orientation) else {
                return false
            }
        }
        return true
    }

    private func matches(
        available: CGSize,
        screen: CGSize,
        orientation: VC.Orientation
    ) -> Bool {
        switch self {
        case let .availableWidth(min, max): Self.inRange(available.width, min: min, max: max)
        case let .availableHeight(min, max): Self.inRange(available.height, min: min, max: max)
        case let .screenWidth(min, max): Self.inRange(screen.width, min: min, max: max)
        case let .screenHeight(min, max): Self.inRange(screen.height, min: min, max: max)
        case let .orientation(value): value == orientation
        }
    }

    /// Inclusive bounds; a nil bound means no limit on that side.
    private static func inRange(_ value: CGFloat, min: Double?, max: Double?) -> Bool {
        if let min, value < CGFloat(min) { return false }
        if let max, value > CGFloat(max) { return false }
        return true
    }
}

#endif
