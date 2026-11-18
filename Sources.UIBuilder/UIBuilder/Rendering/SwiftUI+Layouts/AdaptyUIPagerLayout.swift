//
//  AdaptyUIPagerLayout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Lays out the pages of a `Pager` in a row and sizes its viewport.
///
/// The viewport takes the width the parent proposes. Its height depends on how
/// the page height is given:
/// - a page height of its own — a fixed `page_height`, or `{parent: x}` with
///   `x ≠ 1` under a proposed height — is the height of the viewport, and every
///   page gets it less the page padding;
/// - otherwise the pages are measured with the parent's proposal, less the page
///   padding, and the viewport is as tall as the tallest of them. A page that
///   fills takes the proposed height, a page sized by its content keeps it, and
///   where no height is proposed every page is measured by its content.
///
/// Pages shorter than the viewport are centred in it, as the Android SDK does.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIPagerLayout: Layout {
    let pager: VC.Pager
    let screenSize: CGSize
    let safeArea: EdgeInsets
    let currentPage: Int
    /// The drag translation, already in the layout direction.
    let dragOffset: CGFloat

    struct Geometry {
        var viewport: CGSize
        var pageWidth: CGFloat
        /// The height every page gets, or nil where pages keep their own.
        var exactPageHeight: CGFloat?
        /// What pages are measured and placed with, when they keep their own height.
        var pageProposalHeight: CGFloat?
        var padding: EdgeInsets
        var firstPageInset: CGFloat?
        var lastPageInset: CGFloat?
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        geometry(proposal, subviews).viewport
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var g = geometry(ProposedViewSize(width: bounds.width, height: proposal.height), subviews)
        g.viewport = bounds.size
        let offsetX = VC.Pager.pagesOffsetX(
            currentPage: currentPage,
            pageCount: subviews.count,
            pageWidth: g.pageWidth,
            spacing: pager.spacing,
            viewportWidth: bounds.width,
            firstPageInset: g.firstPageInset,
            lastPageInset: g.lastPageInset,
            pagePaddingLeading: g.padding.leading
        ) + dragOffset
        let area = bounds.height - g.padding.top - g.padding.bottom
        for (index, subview) in subviews.enumerated() {
            let x = bounds.minX + offsetX + g.padding.leading + CGFloat(index) * (g.pageWidth + pager.spacing)
            if let exact = g.exactPageHeight {
                subview.place(
                    at: CGPoint(x: x, y: bounds.minY + g.padding.top),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: g.pageWidth, height: exact)
                )
            } else {
                subview.place(
                    at: CGPoint(x: x, y: bounds.minY + g.padding.top + area / 2),
                    anchor: .leading,
                    proposal: ProposedViewSize(width: g.pageWidth, height: g.pageProposalHeight)
                )
            }
        }
    }

    func explicitAlignment(of _: HorizontalAlignment, in _: CGRect, proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGFloat? {
        nil
    }

    func explicitAlignment(of _: VerticalAlignment, in _: CGRect, proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGFloat? {
        nil
    }

    func geometry(_ proposal: ProposedViewSize, _ subviews: Subviews) -> Geometry {
        let width = proposal.replacingUnspecifiedDimensions().width
        // The proposal is read as it is, as the GeometryReader did and the Android SDK
        // does: inside a scroll a box of `min: screen` and `fill_max` boxes below it
        // still hand down a real length. Only a missing or infinite one counts as none.
        let proposedHeight: CGFloat? = proposal.height.flatMap { $0.isFinite ? $0 : nil }

        let padding = EdgeInsets(
            top: pager.pagePadding.top.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
            leading: pager.pagePadding.leading.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing),
            bottom: pager.pagePadding.bottom.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
            trailing: pager.pagePadding.trailing.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
        )
        let vertical = padding.top + padding.bottom
        let pageWidth = max(
            pager.pageWidth.valueWith(parent: width, screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
                - padding.leading - padding.trailing,
            0
        )
        let firstPageInset = pager.firstPageInset?.valueWith(parent: width, screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
        let lastPageInset = pager.lastPageInset?.valueWith(parent: width, screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)

        func result(_ height: CGFloat, exact: CGFloat?, pageProposal: CGFloat?) -> Geometry {
            Geometry(
                viewport: CGSize(width: width, height: max(height, 0)),
                pageWidth: pageWidth,
                exactPageHeight: exact.map { max($0, 0) },
                pageProposalHeight: pageProposal.map { max($0, 0) },
                padding: padding,
                firstPageInset: firstPageInset,
                lastPageInset: lastPageInset
            )
        }

        switch pager.pageHeight {
        case let .fixed(unit):
            let fixed = unit.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
            return result(fixed, exact: fixed - vertical, pageProposal: nil)
        case let .parent(fraction) where fraction != 1:
            if let proposedHeight {
                return result(proposedHeight * fraction, exact: proposedHeight * fraction - vertical, pageProposal: nil)
            }
            fallthrough
        default:
            let pageProposal = proposedHeight.map { $0 - vertical }
            let tallest = subviews.reduce(CGFloat.zero) { tallest, subview in
                max(tallest, subview.sizeThatFits(ProposedViewSize(width: pageWidth, height: pageProposal)).height)
            }
            return result(tallest + vertical, exact: nil, pageProposal: pageProposal)
        }
    }
}

/// The frame of one page: the page width, and the page height when the pager
/// gives one (`exact`). Otherwise as tall as the page under the proposal, never
/// taller than proposed. The page is centred in it and clipped to it by the caller.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIPagerPageSlot: Layout {
    let exact: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.width ?? subviews.first?.sizeThatFits(proposal).width ?? 0
        if exact, let height = proposal.height { return CGSize(width: width, height: height) }
        let content = subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height ?? 0
        return CGSize(width: width, height: proposal.height.map { min(content, $0) } ?? content)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        subviews.first?.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: ProposedViewSize(bounds.size)
        )
    }

    func explicitAlignment(of _: HorizontalAlignment, in _: CGRect, proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGFloat? {
        nil
    }

    func explicitAlignment(of _: VerticalAlignment, in _: CGRect, proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGFloat? {
        nil
    }
}

#endif
