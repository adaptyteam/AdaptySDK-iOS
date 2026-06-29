//
//  VC.Pager.PagesOffsetTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import CoreGraphics
import Foundation
import Testing

struct VCPagerPagesOffsetTests {
    // 3 pages, page 300pt wide inside a 390pt viewport, no spacing, no padding.
    private func offset(
        clampTrailingGap: Bool,
        page: Int,
        pageCount: Int = 3,
        pageWidth: CGFloat = 300,
        spacing: CGFloat = 0,
        viewportWidth: CGFloat = 390,
        padLeading: CGFloat = 0,
        padTrailing: CGFloat = 0
    ) -> CGFloat {
        VC.Pager.pagesOffsetX(
            clampTrailingGap: clampTrailingGap,
            currentPage: page,
            pageCount: pageCount,
            pageWidth: pageWidth,
            spacing: spacing,
            viewportWidth: viewportWidth,
            pagePaddingLeading: padLeading,
            pagePaddingTrailing: padTrailing
        )
    }

    // MARK: - clamp off (legacy: every page leading-snapped, trailing gap allowed)

    @Test("clamp off: first page is flush-leading")
    func clampOffFirstPage() {
        #expect(offset(clampTrailingGap: false, page: 0) == 0)
    }

    @Test("clamp off: last page stays leading-snapped (keeps the trailing gap)")
    func clampOffLastPage() {
        // page 2 left edge = 2*300 - 600 = 0 → flush-left, 90pt empty on the right.
        #expect(offset(clampTrailingGap: false, page: 2) == -600)
    }

    // MARK: - clamp on (clamp scroll to content bounds)

    @Test("clamp on: first page unchanged, still flush-leading")
    func clampOnFirstPage() {
        #expect(offset(clampTrailingGap: true, page: 0) == 0)
    }

    @Test("clamp on: middle page still leading-snapped while room remains")
    func clampOnMiddlePage() {
        #expect(offset(clampTrailingGap: true, page: 1) == -300)
    }

    @Test("clamp on: last page is pinned to the trailing edge (no gap)")
    func clampOnLastPage() {
        // contentWidth = 3*300 = 900; minOffset = 390 - 900 = -510.
        // unclamped would be -600 → clamped to -510 so the last page right edge
        // lands exactly on the viewport trailing edge.
        #expect(offset(clampTrailingGap: true, page: 2) == -510)
    }

    @Test("clamp on: respects page padding")
    func clampOnRespectsPadding() {
        // contentWidth = 10 + 3*300 + 20 = 930; minOffset = 390 - 930 = -540.
        #expect(offset(clampTrailingGap: true, page: 2, padLeading: 10, padTrailing: 20) == -540)
    }

    @Test("clamp on: when all content fits, no scrolling past leading")
    func clampOnContentFits() {
        // 2 pages of 150 in a 390 viewport → contentWidth 300 < 390, minOffset clamped to 0.
        #expect(offset(clampTrailingGap: true, page: 1, pageCount: 2, pageWidth: 150) == 0)
    }
}
