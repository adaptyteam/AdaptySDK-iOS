//
//  AdaptyUIFlexView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIFlexView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation

    private let flex: VC.Flex
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ flex: VC.Flex,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.flex = flex
        self.screenHolderBuilder = screenHolderBuilder
    }

    /// Space offered by the parent, sampled from the greedy GeometryReader on the
    /// axes it is still free to fill. Feeds the `available_*` conditions only.
    @State private var availableSize: CGSize = .zero
    @State private var direction: VC.Flex.Direction = .vertical
    /// Intrinsic size of the content in the current direction, reported by the row /
    /// column body. Pinned back onto the greedy GeometryReader on every axis that
    /// has to hug — see `hugWidth` / `hugHeight`.
    @State private var contentSize: CGSize = .zero

    /// Width the flex shrinks to, or nil while the width axis stays greedy.
    ///
    /// Row mode: width is the main axis, so `width: "hug"` has to shrink the flex to
    /// its content — otherwise the greedy GeometryReader keeps the whole proposal and
    /// `hug` renders pixel-for-pixel like `fill`.
    /// Column mode: width is the cross axis, and a column fills it just like Column.
    private var hugWidth: CGFloat? {
        guard direction == .horizontal, flex.width == .hug, contentSize.width > 0 else { return nil }
        return contentSize.width
    }

    /// Height the flex shrinks to, or nil while the height axis stays greedy.
    ///
    /// Row mode: height is the cross axis and the row always hugs it (FlexRowView
    /// reports an intrinsic height via fixedSize), otherwise the flex collapses to
    /// ~10pt when the parent proposes nil height — a ScrollView's scroll axis.
    /// Column mode: height is the main axis — `hug` shrinks to the content, `fill`
    /// stays greedy because the weights are computed from the proposal.
    private var hugHeight: CGFloat? {
        guard contentSize.height > 0 else { return nil }
        switch direction {
        case .horizontal: return contentSize.height
        case .vertical: return flex.height == .hug ? contentSize.height : nil
        }
    }

    private func computedDirection(orientation: VC.Orientation) -> VC.Flex.Direction {
        let match = VC.Condition.evaluate(
            flex.condition,
            available: availableSize,
            screen: screenSize,
            orientation: orientation
        )
        return match ? flex.direction : flex.direction.opposite
    }

    var body: some View {
        GeometryReader { proxy in
            content(available: proxy.size)
                .onGeometrySizeChange { contentSize = $0 }
                .onAppear {
                    availableSize = parentProposal(from: proxy.size)
                    direction = computedDirection(orientation: orientation)
                }
                .onChange(of: proxy.size) { newSize in
                    let proposal = parentProposal(from: newSize)
                    guard proposal != availableSize else { return }
                    availableSize = proposal
                    recompute(orientation: orientation)
                }
                .onChange(of: screenSize) { _ in recompute(orientation: orientation) }
                .onChange(of: orientation) { newOrientation in recompute(orientation: newOrientation) }
        }
        // Every hugging axis pins the greedy reader to the measured content, so the
        // flex's own frame (and with it its decorator and the parent's alignment)
        // matches the content instead of the whole proposal. A nil axis stays greedy.
        // Both pins converge without churn: the content ignores the proposal on the
        // pinned axis (fixed item lengths, fixedSize on the row's cross axis).
        .frame(width: hugWidth, height: hugHeight)
    }

    /// Space offered by the parent. A pinned axis is skipped: `proxy.size` there only
    /// echoes our own pin, and feeding that back into the conditions makes the
    /// direction self-oscillate — hugging drops the flex below an `available_*`
    /// threshold, it flips to the other direction, which is greedy on that axis
    /// again, the threshold passes, and it flips straight back.
    ///
    /// The first pass always runs unpinned (nothing is measured yet), so the initial
    /// direction is resolved against the real proposal. Afterwards a pinned axis
    /// keeps that reading: a hugging flex cannot observe the parent shrinking behind
    /// its own frame, so `available_*` on a hugging axis is sampled once. `screen_*`
    /// and `orientation` come from the environment and stay live.
    private func parentProposal(from proxySize: CGSize) -> CGSize {
        .init(
            width: hugWidth == nil ? proxySize.width : availableSize.width,
            height: hugHeight == nil ? proxySize.height : availableSize.height
        )
    }

    @ViewBuilder
    private func content(available: CGSize) -> some View {
        switch direction {
        case .horizontal:
            let row = flex.asRow
            switch row.width {
            case .legacy:
                AdaptyUIRowView(row, screenHolderBuilder: screenHolderBuilder)
            case .hug, .fill:
                AdaptyUIFlexRowView(row, externalSize: available, screenHolderBuilder: screenHolderBuilder)
            }
        case .vertical:
            let column = flex.asColumn
            switch column.height {
            case .legacy:
                AdaptyUIColumnView(column, screenHolderBuilder: screenHolderBuilder)
            case .hug, .fill:
                AdaptyUIFlexColumnView(column, externalSize: available, screenHolderBuilder: screenHolderBuilder)
            }
        }
    }

    private func recompute(orientation: VC.Orientation) {
        let newDirection = computedDirection(orientation: orientation)
        guard newDirection != direction else { return }
        // `contentSize` is deliberately not reset here: the observer only re-fires when
        // the measured size actually changes, so zeroing it would strand the pin (and
        // with it the hug) whenever both directions happen to measure the same. The
        // flipped content re-measures on its own, and until it does the previous
        // reading is the closest available — for identical sizes it is already exact.
        if let transition = flex.transition {
            withAnimation(transition.swiftUIAnimation) { direction = newDirection }
        } else {
            direction = newDirection
        }
    }
}

#endif
