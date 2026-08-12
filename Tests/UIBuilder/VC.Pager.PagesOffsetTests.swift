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
        page: Int,
        pageCount: Int = 3,
        pageWidth: CGFloat = 300,
        spacing: CGFloat = 0,
        viewportWidth: CGFloat = 390,
        firstInset: CGFloat? = nil,
        lastInset: CGFloat? = nil,
        padLeading: CGFloat = 0
    ) -> CGFloat {
        VC.Pager.pagesOffsetX(
            currentPage: page,
            pageCount: pageCount,
            pageWidth: pageWidth,
            spacing: spacing,
            viewportWidth: viewportWidth,
            firstPageInset: firstInset,
            lastPageInset: lastInset,
            pagePaddingLeading: padLeading
        )
    }

    // MARK: - no insets (legacy: every page leading-snapped, trailing gap allowed)

    @Test("no insets: first page is flush-leading")
    func legacyFirstPage() {
        #expect(offset(page: 0) == 0)
    }

    @Test("no insets: last page stays leading-snapped (keeps the trailing gap)")
    func legacyLastPage() {
        // page 2 left edge = 2*300 - 600 = 0 → flush-left, 90pt empty on the right.
        #expect(offset(page: 2) == -600)
    }

    // MARK: - first_page_inset (rest position of the first page only)

    @Test("first inset: first page rests at the inset instead of page padding")
    func firstInsetOverridesPadding() {
        // rest = 16 - 24 = -8 → first page leading edge lands 16pt from the viewport edge.
        #expect(offset(page: 0, firstInset: 16, padLeading: 24) == -8)
    }

    @Test("first inset: middle and last pages are unaffected, no clamp implied")
    func firstInsetLeavesOtherPagesAlone() {
        #expect(offset(page: 1, firstInset: 16) == -300)
        #expect(offset(page: 2, firstInset: 16) == -600)
    }

    // MARK: - last_page_inset (clamp scroll to content bounds)

    @Test("last inset: first page unchanged, still flush-leading")
    func lastInsetFirstPage() {
        #expect(offset(page: 0, lastInset: 20) == 0)
    }

    @Test("last inset: middle page still leading-snapped while room remains")
    func lastInsetMiddlePage() {
        #expect(offset(page: 1, lastInset: 20) == -300)
    }

    @Test("last inset: last page rests at the inset from the trailing edge")
    func lastInsetClampsLastPage() {
        // contentWidth = 3*300 + 20 = 920; minOffset = 390 - 920 = -530.
        // unclamped would be -600 → clamped to -530 so the last page right edge
        // lands 20pt from the viewport trailing edge.
        #expect(offset(page: 2, lastInset: 20) == -530)
    }

    @Test("last inset: clamp accounts for the rendered leading page padding")
    func lastInsetRespectsLeadingPadding() {
        // contentWidth = 10 + 3*300 + 20 = 930; minOffset = 390 - 930 = -540.
        #expect(offset(page: 2, lastInset: 20, padLeading: 10) == -540)
    }

    // MARK: - both insets

    @Test("both insets: first page rest wins over the trailing clamp")
    func bothInsetsFirstPage() {
        #expect(offset(page: 0, firstInset: 16, lastInset: 20, padLeading: 24) == -8)
    }

    @Test("both insets: when all content fits, pages rest at the first page inset")
    func bothInsetsContentFits() {
        // 2 pages of 150 in a 390 viewport → contentWidth = 300 + 10 = 310 < 390.
        // The clamp never pushes pages past the first page rest (16).
        #expect(offset(page: 1, pageCount: 2, pageWidth: 150, firstInset: 16, lastInset: 10) == 16)
    }
}
