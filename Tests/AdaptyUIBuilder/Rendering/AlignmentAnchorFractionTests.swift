//
//  AlignmentAnchorFractionTests.swift
//  AdaptyTests
//
//  Created by Aleksey Goncharov on 15.09.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import SwiftUI
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Deck Layout"),
    .feature("Deck Rendering"),
    .risk(.normal),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct AlignmentAnchorFractionTests {
    /// Logical alignments follow the interface direction, physical ones do not, and
    /// `justified` stays centered.
    @Test(
        "Horizontal fractions follow the layout direction",
        arguments: [
            (VC.HorizontalAlignment.leading, LayoutDirection.leftToRight, CGFloat(0)),
            (.leading, .rightToLeft, 0),
            (.trailing, .leftToRight, 1),
            (.trailing, .rightToLeft, 1),
            (.center, .leftToRight, 0.5),
            (.justified, .leftToRight, 0.5),
            (.justified, .rightToLeft, 0.5),
            (.left, .leftToRight, 0),
            (.left, .rightToLeft, 1),
            (.right, .leftToRight, 1),
            (.right, .rightToLeft, 0),
        ]
    )
    func horizontalFractions(
        alignment: VC.HorizontalAlignment,
        layoutDirection: LayoutDirection,
        expected: CGFloat
    ) {
        #expect(alignment.anchorFraction(with: layoutDirection) == expected)
    }

    @Test(
        "Vertical fractions run from top to bottom",
        arguments: [
            (VC.VerticalAlignment.top, CGFloat(0)),
            (.center, 0.5),
            (.bottom, 1),
        ]
    )
    func verticalFractions(alignment: VC.VerticalAlignment, expected: CGFloat) {
        #expect(alignment.anchorFraction == expected)
    }
}
