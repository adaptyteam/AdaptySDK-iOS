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
        AdaptyUIElementView(
            selectedElement,
            screenHolderBuilder: screenHolderBuilder
        )
        .onAppear { selection = computedSelection(orientation: orientation) }
        .onGeometrySizeChange { newSize in
            guard newSize != availableSize else { return }
            availableSize = newSize
            recompute(orientation: orientation)
        }
        .onChange(of: screenSize) { _ in recompute(orientation: orientation) }
        .onChange(of: orientation) { newOrientation in recompute(orientation: newOrientation) }
    }

    private func recompute(orientation: VC.Orientation) {
        let newSelection = computedSelection(orientation: orientation)
        guard newSelection != selection else { return }
        if let transition = switchElement.transition {
            withAnimation(transition.swiftUIAnimation) { selection = newSelection }
        } else {
            selection = newSelection
        }
    }
}

#endif
