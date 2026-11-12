//
//  AdaptyUILineHeightAdjustmentTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import CoreGraphics
import Foundation
import Testing

struct AdaptyUILineHeightAdjustmentTests {
    @Test("no line_height: nothing is applied")
    func noLineHeight() {
        #expect(AdaptyUILineHeightAdjustment(lineHeight: nil, naturalLineHeight: 62) == nil)
    }

    @Test("line_height equal to the natural height: nothing is applied")
    func naturalLineHeight() {
        #expect(AdaptyUILineHeightAdjustment(lineHeight: 62, naturalLineHeight: 62) == nil)
    }

    @Test("unknown natural height: nothing is applied")
    func zeroNaturalHeight() {
        #expect(AdaptyUILineHeightAdjustment(lineHeight: 40, naturalLineHeight: 0) == nil)
    }

    @Test("tighter than the font: multiple below 1, lost space returned on top")
    func tighterLine() throws {
        let adjustment = try #require(AdaptyUILineHeightAdjustment(lineHeight: 40, naturalLineHeight: 62))
        #expect(adjustment.multiple == 40.0 / 62.0)
        #expect(adjustment.topPadding == 22)
    }

    @Test("looser than the font: multiple above 1, no padding")
    func looserLine() throws {
        let adjustment = try #require(AdaptyUILineHeightAdjustment(lineHeight: 20, naturalLineHeight: 16))
        #expect(adjustment.multiple == 1.25)
        #expect(adjustment.topPadding == 0)
    }
}
