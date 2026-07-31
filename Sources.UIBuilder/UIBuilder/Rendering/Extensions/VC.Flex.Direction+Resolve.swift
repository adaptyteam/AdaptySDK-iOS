//
//  VC.Flex.Direction+Resolve.swift
//  AdaptyUIBuilder
//

// Decision logic shared by `AdaptyUIWeightedStackLayout` (Flex) and
// `AdaptyUIFlexStackLayout`: both resolve their axis the same way, so the rule lives
// in one place rather than twice.

#if canImport(UIKit)

import CoreGraphics
import Foundation

extension VC.Flex.Direction {
    /// Which axis a conditional container lays out along.
    ///
    /// `available` is `nil` when the proposal did not carry an axis the conditions
    /// read (see `VC.Condition.availableSize(for:proposal:)`); the caller passes the
    /// direction it used last so a probe cannot flip the answer mid-pass.
    ///
    /// - Parameters:
    ///   - conditions: the container's conditions; empty means "always matches".
    ///   - matched: the direction declared in the config, used when they match.
    ///   - available: the offered size, or `nil` when undecidable.
    ///   - lastResolved: direction from the previous decidable pass, if any.
    static func resolve(
        conditions: [VC.Condition],
        matched: VC.Flex.Direction,
        available: CGSize?,
        screen: CGSize,
        orientation: VC.Orientation,
        lastResolved: VC.Flex.Direction?
    ) -> VC.Flex.Direction {
        guard let available else {
            // A probe, not a real offer. Keep what the last real proposal produced;
            // on a very first probe fall back to the declared direction rather than
            // inventing one from a synthetic size.
            return lastResolved ?? matched
        }

        let matches = VC.Condition.evaluate(
            conditions,
            available: available,
            screen: screen,
            orientation: orientation
        )
        return matches ? matched : matched.opposite
    }
}

#endif
