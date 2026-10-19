//
//  AdaptyUISwitchView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Renders a `Switch`: the first case whose conditions hold, `default` when none
/// does, and only that one, so the branches not shown are never built.
///
/// Conditions on the screen, the device and the orientation are read in `body`
/// and right on the first frame. A condition on `available_*` needs what the
/// parent proposes, which only a layout pass shows: until a probe in
/// `AdaptyUISwitchLayout` reports it, the screen stands in. That first
/// correction is not animated; a later change of branch is, with the transition.
@MainActor
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUISwitchView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation
    @Environment(\.adaptyUnspecifiedProposalAxes) private var unspecifiedAxes: Axis.Set

    private let switchElement: VC.Switch
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ switch: VC.Switch,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.switchElement = `switch`
        self.screenHolderBuilder = screenHolderBuilder
    }

    /// What the parent offers, as the probe last reported it; nil until it has.
    @State private var available: CGSize?

    private func selection(_ available: CGSize?) -> VC.ElementIndex {
        switchElement.selectedContent(available: available ?? screenSize, screen: screenSize, orientation: orientation)
    }

    var body: some View {
        if let animation = switchElement.transition?.swiftUIAnimation {
            content
                .animation(animation, value: screenSize)
                .animation(animation, value: orientation)
        } else {
            content
        }
    }

    private var content: some View {
        let probes = switchElement.readsAvailableSize
        return AdaptyUISwitchLayout(screenSize: screenSize, probes: probes, unspecifiedAxes: unspecifiedAxes) {
            if probes {
                Color.clear
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .onGeometrySizeChange { report($0) }
            }
            AdaptyUIElementView(
                selection(available),
                screenHolderBuilder: screenHolderBuilder
            )
        }
    }

    private func report(_ size: CGSize) {
        guard size != available else { return }
        let changesBranch = available != nil && selection(available) != selection(size)
        if changesBranch, let animation = switchElement.transition?.swiftUIAnimation {
            withAnimation(animation) { available = size }
        } else {
            available = size
        }
    }
}

#endif
