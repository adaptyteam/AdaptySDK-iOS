//
//  AdaptyUILayoutSizing.swift
//  AdaptyUIBuilder
//

import Foundation

/// How a layout container sizes itself along one axis.
///
/// Free of SwiftUI so the solvers can take it on a plain `swift test`.
enum AdaptyUILayoutSizing: Equatable {
    /// The container takes the size of its content.
    case hug
    /// The container takes the proposal. What it takes without one is the
    /// container's own rule.
    case fill
}
