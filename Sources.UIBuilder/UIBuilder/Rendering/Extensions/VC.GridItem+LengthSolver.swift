//
//  VC.GridItem+LengthSolver.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import CoreGraphics
import Foundation

extension VC.GridItem {
    /// One item's length along the axis a `Row` / `Column` distributes, with
    /// `fixed` already resolved to points.
    ///
    /// Resolving a `VC.Unit` needs the screen size and the safe area, which only
    /// the view layer has, so the caller does that conversion and this solver
    /// stays pure arithmetic — testable without a SwiftUI host.
    enum ResolvedLength: Equatable, Sendable {
        case fixed(CGFloat)
        case weight(Int)
    }

    /// Total weight of `lengths` and the length reserved by everything that is
    /// not weighted.
    ///
    /// Mirrors `calculateTotalWeight` in the current Row / Column bodies: fixed
    /// lengths and the inter-item spacing are reserved, weights are summed.
    static func reservedLength(
        _ lengths: [ResolvedLength],
        spacing: Double
    ) -> (totalWeight: Int, reserved: CGFloat) {
        var totalWeight = 0
        var reserved: CGFloat = 0

        for length in lengths {
            switch length {
            case let .fixed(value): reserved += value
            case let .weight(value): totalWeight += value
            }
        }

        if spacing > 0 {
            reserved += CGFloat(spacing * Double(max(0, lengths.count - 1)))
        }

        return (totalWeight, reserved)
    }

    /// Length of every item when the axis distributes `availableLength`
    /// (`fill` and `legacy` sizing).
    ///
    /// `availableLength == nil` means nothing has been proposed on that axis yet.
    /// Weighted items then come back as `nil`, so the caller leaves them
    /// unconstrained rather than collapsing them to 0 — at width 0 texts vanish
    /// and their ideal height explodes.
    ///
    /// A `nil` element in the result means "do not constrain this item".
    static func distributedLengths(
        _ lengths: [ResolvedLength],
        spacing: Double,
        availableLength: CGFloat?
    ) -> [CGFloat?] {
        let (totalWeight, reserved) = reservedLength(lengths, spacing: spacing)
        // Reserved length can exceed what is available; weights then get nothing
        // rather than a negative share.
        let weightsAvailable = availableLength.map { max(0, $0 - reserved) }

        return lengths.map { length -> CGFloat? in
            switch length {
            case let .fixed(value):
                return value
            case let .weight(weight):
                return weightsAvailable.map { available in
                    guard totalWeight > 0 else { return 0 }
                    return (CGFloat(weight) / CGFloat(totalWeight)) * available
                }
            }
        }
    }

    /// Length of every item when the axis hugs its content (`hug` sizing).
    ///
    /// Weighted items collapse to 0: a proportion of an unbounded length has no
    /// meaning. This reproduces today's behaviour, where the hug bodies call the
    /// solver with `totalWeight: 0, weightsAvailableLength: 0` and so pin every
    /// weighted item to `0`.
    static func huggedLengths(_ lengths: [ResolvedLength]) -> [CGFloat?] {
        lengths.map { length -> CGFloat? in
            switch length {
            case let .fixed(value): return value
            case .weight: return 0
            }
        }
    }
}

#endif
