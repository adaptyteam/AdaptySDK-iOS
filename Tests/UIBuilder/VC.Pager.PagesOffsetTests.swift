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
        _ positioning: VC.Pager.LastPagePositioning,
        page: Int,
        pageCount: Int = 3,
        pageWidth: CGFloat = 300,
        spacing: CGFloat = 0,
        viewportWidth: CGFloat = 390,
        padLeading: CGFloat = 0,
        padTrailing: CGFloat = 0
    ) -> CGFloat {
        VC.Pager.pagesOffsetX(
            positioning: positioning,
            currentPage: page,
            pageCount: pageCount,
            pageWidth: pageWidth,
            spacing: spacing,
            viewportWidth: viewportWidth,
            pagePaddingLeading: padLeading,
            pagePaddingTrailing: padTrailing
        )
    }

    // MARK: - .leading (legacy: every page leading-snapped, trailing gap allowed)

    @Test("leading: first page is flush-leading")
    func leadingFirstPage() {
        #expect(offset(.leading, page: 0) == 0)
    }

    @Test("leading: last page stays leading-snapped (keeps the trailing gap)")
    func leadingLastPage() {
        // page 2 left edge = 2*300 - 600 = 0 → flush-left, 90pt empty on the right.
        #expect(offset(.leading, page: 2) == -600)
    }

    // MARK: - .trailing (clamp scroll to content bounds)

    @Test("trailing: first page unchanged, still flush-leading")
    func trailingFirstPage() {
        #expect(offset(.trailing, page: 0) == 0)
    }

    @Test("trailing: middle page still leading-snapped while room remains")
    func trailingMiddlePage() {
        #expect(offset(.trailing, page: 1) == -300)
    }

    @Test("trailing: last page is pinned to the trailing edge (no gap)")
    func trailingLastPage() {
        // contentWidth = 3*300 = 900; minOffset = 390 - 900 = -510.
        // unclamped would be -600 → clamped to -510 so the last page right edge
        // lands exactly on the viewport trailing edge.
        #expect(offset(.trailing, page: 2) == -510)
    }

    @Test("trailing: clamp respects page padding")
    func trailingRespectsPadding() {
        // contentWidth = 10 + 3*300 + 20 = 930; minOffset = 390 - 930 = -540.
        #expect(offset(.trailing, page: 2, padLeading: 10, padTrailing: 20) == -540)
    }

    @Test("trailing: when all content fits, no scrolling past leading")
    func trailingContentFits() {
        // 2 pages of 150 in a 390 viewport → contentWidth 300 < 390, minOffset clamped to 0.
        #expect(offset(.trailing, page: 1, pageCount: 2, pageWidth: 150) == 0)
    }
}
