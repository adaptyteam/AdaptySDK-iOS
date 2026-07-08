//
//  VC.Pager+PagesOffset.swift
//  AdaptyUIBuilder
//

import Foundation

extension VC.Pager {
    /// Horizontal base offset (X) of the pages stack for `currentPage`, before
    /// the live drag translation is added.
    ///
    /// By default every page rests leading-snapped at `pagePaddingLeading`
    /// (legacy behaviour, may leave an empty trailing gap on the last page).
    ///
    /// `firstPageInset` overrides `pagePaddingLeading` for the rest position
    /// of the first page only. `lastPageInset` clamps the scroll so the last
    /// page rests with its trailing edge `lastPageInset` away from the
    /// viewport trailing edge instead of leading-snapping. A `nil` inset
    /// keeps the legacy behaviour for its edge.
    static func pagesOffsetX(
        currentPage: Int,
        pageCount: Int,
        pageWidth: CGFloat,
        spacing: CGFloat,
        viewportWidth: CGFloat,
        firstPageInset: CGFloat?,
        lastPageInset: CGFloat?,
        pagePaddingLeading: CGFloat
    ) -> CGFloat {
        let step = pageWidth + spacing
        let firstPageRest = firstPageInset.map { $0 - pagePaddingLeading } ?? 0
        let rest = currentPage == 0 ? firstPageRest : -CGFloat(currentPage) * step

        guard let lastPageInset else { return rest }

        // The stack is laid out with `pagePaddingLeading` before the first
        // page, so the clamp uses it regardless of `firstPageInset`.
        let contentWidth = pagePaddingLeading
            + CGFloat(pageCount) * pageWidth
            + CGFloat(max(0, pageCount - 1)) * spacing
            + lastPageInset
        let minOffset = min(firstPageRest, viewportWidth - contentWidth)
        return max(minOffset, rest)
    }
}
