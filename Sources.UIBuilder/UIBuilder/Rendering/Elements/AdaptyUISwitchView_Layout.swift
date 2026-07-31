//
//  AdaptyUISwitchView_Layout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `Layout`-based counterpart of `AdaptyUISwitchView`, selected by the `#available`
/// branch in `AdaptyUIElementView`. The original view is untouched and keeps
/// serving iOS 15 / macOS 12.
///
/// Switch is the odd one out: it branches its **content**, not its direction, and
/// the branch has to be chosen while the body is built, before any proposal is
/// known. Handing every case to a `Layout` as `subviews` and placing only the
/// selected one is not an option — unplaced and even unmeasured subviews still get
/// `body`, `onAppear` and `task`, so unselected branches would start video
/// autoplay, image loads and analytics.
///
/// So the selection stays outside the layout, and the split is by what the
/// conditions actually read:
///
/// - **environment only** (`orientation`, `screen_*`): the selection is a pure
///   function of the environment. No measuring, no `@State`, and it re-evaluates on
///   its own whenever the environment changes.
/// - **`available_*`**: the offered size is still needed, so a probe subview reports
///   it back. That keeps one measurement round-trip, exactly as today.
///
/// What goes away in both cases is the sizing hack: the greedy `GeometryReader` and
/// the `@State contentsSize` floor over it. `AdaptyUIGreedyContentLayout` applies
/// the same "greedy where bounded, never below the content" rule, recomputed from
/// the current proposal, so narrowing the parent no longer leaves a stale wider
/// floor behind — which a switch whose cases read only `orientation` never recovers
/// from, since nothing else resets it.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
struct AdaptyUISwitchView_Layout<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation)
    private var orientation: VC.Orientation

    private let switchElement: VC.Switch
    private let screenHolderBuilder: () -> ScreenHolderContent
    /// Decided once from the config: does any case tie its answer to the offered
    /// size, or is the whole switch a function of the environment?
    private let readsAvailableSize: Bool

    init(
        _ switch: VC.Switch,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        switchElement = `switch`
        self.screenHolderBuilder = screenHolderBuilder
        readsAvailableSize = `switch`.cases.contains {
            VC.Condition.readsAvailableSize($0.condition)
        }
    }

    /// Only used by the `available_*` path; stays `.zero` otherwise.
    @State private var availableSize: CGSize = .zero

    /// Index of the selected case; -1 → default.
    private func selection(available: CGSize) -> Int {
        for (index, item) in switchElement.cases.enumerated() {
            if VC.Condition.evaluate(
                item.condition,
                available: available,
                screen: screenSize,
                orientation: orientation
            ) {
                return index
            }
        }
        return -1
    }

    private func element(at selection: Int) -> VC.ElementIndex {
        if selection >= 0, selection < switchElement.cases.count {
            switchElement.cases[selection].content
        } else {
            switchElement.default
        }
    }

    var body: some View {
        // Recomputed on every body evaluation rather than stored: for the
        // environment-only case that is what makes the choice live without a
        // `@State` mirror to keep in sync.
        let selection = selection(available: availableSize)

        AdaptyUIGreedyContentLayout {
            AdaptyUIElementView(
                element(at: selection),
                screenHolderBuilder: screenHolderBuilder
            )

            if readsAvailableSize {
                // Sized by the layout to the offered size, reduced to the axes the
                // parent actually bounded, and observed here. Nothing to draw.
                Color.clear
                    .layoutValue(key: AdaptyUIAvailableSizeProbeKey.self, value: true)
                    .onGeometrySizeChange { newValue in
                        guard newValue != availableSize else { return }
                        availableSize = newValue
                    }
            }
        }
        // Replaces the manual `withAnimation` around the state write: there is no
        // single write to wrap when the selection follows the environment.
        .animation(switchElement.transition?.swiftUIAnimation, value: selection)
    }
}

#endif
