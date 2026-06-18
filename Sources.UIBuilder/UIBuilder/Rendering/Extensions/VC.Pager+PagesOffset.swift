//
//  VC.Pager+PagesOffset.swift
//  AdaptyUIBuilder
//

import Foundation

extension VC.Pager {
    /// Horizontal base offset (X) of the pages stack for `currentPage`, before
    /// the live drag translation is added.
    ///
    /// For `.leading` the active page is leading-snapped (legacy behaviour, may
    /// leave an empty trailing gap on the last page). For `.trailing` the scroll
    /// is clamped so the content never reveals empty space past its trailing
    /// edge, pinning the last page to the trailing edge of the viewport.
    static func pagesOffsetX(
        positioning: LastPagePositioning,
        currentPage: Int,
        pageCount: Int,
        pageWidth: CGFloat,
        spacing: CGFloat,
        viewportWidth: CGFloat,
        pagePaddingLeading: CGFloat,
        pagePaddingTrailing: CGFloat
    ) -> CGFloat {
        let step = pageWidth + spacing
        let unclamped = -CGFloat(currentPage) * step

        switch positioning {
        case .leading:
            return unclamped
        case .trailing:
            let contentWidth = pagePaddingLeading
                + CGFloat(pageCount) * pageWidth
                + CGFloat(max(0, pageCount - 1)) * spacing
                + pagePaddingTrailing
            let minOffset = min(0, viewportWidth - contentWidth)
            return max(minOffset, unclamped)
        }
    }
}
