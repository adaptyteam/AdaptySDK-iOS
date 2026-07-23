//
//  AdaptyUISwitchView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUISwitchView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation

    private let switchElement: VC.Switch
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ switch: VC.Switch,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.switchElement = `switch`
        self.screenHolderBuilder = screenHolderBuilder
    }

    @State private var availableSize: CGSize = .zero
    /// Index of the selected case; -1 → default.
    @State private var selection: Int = -1
    /// Natural size of the selected branch. Used as a floor on the greedy
    /// GeometryReader so it can't collapse below its content when the parent
    /// proposes nil on an axis (e.g. the scroll axis of a ScrollView).
    @State private var contentsSize: CGSize = .zero

    private func computedSelection(orientation: VC.Orientation) -> Int {
        for (index, item) in switchElement.cases.enumerated() {
            if VC.Condition.evaluate(
                item.condition,
                available: availableSize,
                screen: screenSize,
                orientation: orientation
            ) {
                return index
            }
        }
        return -1
    }

    private var selectedElement: VC.ElementIndex {
        if selection >= 0, selection < switchElement.cases.count {
            switchElement.cases[selection].content
        } else {
            switchElement.default
        }
    }

    var body: some View {
        GeometryReader { proxy in
            AdaptyUIElementView(
                selectedElement,
                screenHolderBuilder: screenHolderBuilder
            )
            .onGeometrySizeChange { contentsSize = $0 }
            .onAppear {
                availableSize = proxy.size
                selection = computedSelection(orientation: orientation)
            }
            .onChange(of: proxy.size) { newSize in
                guard newSize != availableSize else { return }
                availableSize = newSize
                recompute(orientation: orientation)
            }
            .onChange(of: screenSize) { _ in recompute(orientation: orientation) }
            .onChange(of: orientation) { newOrientation in recompute(orientation: newOrientation) }
        }
        // Floor the greedy reader at the content size: `proxy.size` still equals the
        // parent proposal when bounded (so the condition reads it), but the view can't
        // collapse to ~10pt when the parent proposes nil (a ScrollView scroll axis).
        .frame(minWidth: contentsSize.width, minHeight: contentsSize.height)
    }

    private func recompute(orientation: VC.Orientation) {
        let newSelection = computedSelection(orientation: orientation)
        guard newSelection != selection else { return }
        // Drop the stale floor so the incoming branch re-measures from scratch;
        // otherwise a larger previous branch would over-size a smaller new one.
        contentsSize = .zero
        if let transition = switchElement.transition {
            withAnimation(transition.swiftUIAnimation) { selection = newSelection }
        } else {
            selection = newSelection
        }
    }
}

#endif
