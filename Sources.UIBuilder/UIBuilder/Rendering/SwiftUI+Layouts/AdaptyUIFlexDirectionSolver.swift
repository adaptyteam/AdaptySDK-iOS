//
//  AdaptyUIFlexDirectionSolver.swift
//  AdaptyUIBuilder
//

import Foundation

/// Picks the direction of a `flex` or a `flex_stack` from its conditions.
///
/// `available_width` and `available_height` read, per axis:
/// - the proposed length, zero and infinity included;
/// - without one, under a box that shrinks on that axis, the container's own
///   length laid out in `direction`: the direction it takes when the conditions
///   hold, so the answer does not depend on which direction was drawn before;
/// - without one anywhere else — a scroll axis, a `deck` cell without a length, a
///   hugging footer — the screen.
///
/// The answer is a function of its arguments only, so a layout can ask it on
/// every pass instead of remembering a direction between them. Free of SwiftUI
/// and of `#if canImport(UIKit)`, so it runs under a plain `swift test`.
enum AdaptyUIFlexDirectionSolver {
    /// - Parameters:
    ///   - hugsWidth, hugsHeight: a box with `shrink` hugs the container on that
    ///     axis. Only read where the proposal on the axis is `nil`.
    ///   - naturalSize: the container's size laid out in `direction` for the same
    ///     proposal. Asked at most once, and only when a hugged axis without a
    ///     proposal is compared.
    static func direction(
        conditions: [VC.Condition],
        direction: VC.Flex.Direction,
        proposedWidth: CGFloat?,
        proposedHeight: CGFloat?,
        hugsWidth: Bool,
        hugsHeight: Bool,
        screen: CGSize,
        orientation: VC.Orientation,
        naturalSize: () -> CGSize
    ) -> VC.Flex.Direction {
        var natural: CGSize?
        func available(_ proposed: CGFloat?, hugged: Bool, _ length: KeyPath<CGSize, CGFloat>) -> CGFloat {
            if let proposed { return proposed }
            guard hugged else { return screen[keyPath: length] }
            if natural == nil { natural = naturalSize() }
            return natural![keyPath: length]
        }

        // An axis no condition reads is not resolved, so the container is not
        // measured for a length nobody compares.
        var readsWidth = false, readsHeight = false
        for condition in conditions {
            switch condition {
            case .availableWidth: readsWidth = true
            case .availableHeight: readsHeight = true
            case .screenWidth, .screenHeight, .orientation: break
            }
        }

        let holds = VC.Condition.evaluate(
            conditions,
            available: CGSize(
                width: readsWidth ? available(proposedWidth, hugged: hugsWidth, \.width) : 0,
                height: readsHeight ? available(proposedHeight, hugged: hugsHeight, \.height) : 0
            ),
            screen: screen,
            orientation: orientation
        )

        return holds ? direction : direction.opposite
    }
}
