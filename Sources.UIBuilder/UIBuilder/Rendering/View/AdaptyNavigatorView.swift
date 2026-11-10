//
//  AdaptyNavigatorView.swift
//  Adapty
//
//  Created by Alex Goncharov on 23/01/2026.
//

#if canImport(UIKit)

import SwiftUI

extension VC {
    static let templateIdBasic = "basic"
    static let templateIdFlat = "flat"
    static let templateIdTransparent = "transparent"
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyScreenView: View {
    var screen: VC.Screen

    @EnvironmentObject
    private var flowViewModel: AdaptyUIFlowViewModel
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel
    @EnvironmentObject
    private var screenInstance: AdaptyUIScreenViewModel

    @State
    private var playIncomingTransition: [VC.Animation] = []

    @State
    private var playOutgoingTransition: [VC.Animation] = []

    var body: some View {
        let incomingAnimations = screenInstance.playIncomingTransition ?? []

        templateResolverView(
            screenInstance.configuration.layoutBehaviour,
            screen: screenInstance.configuration
        )
        .withScreenInstance(screenInstance.instance)
        .withElementPool(screenInstance.configuration.poolElements)
        .animatablePropertiesTransition(
            play: $playIncomingTransition,
            initialOpacity: incomingAnimations.transitionInitialOpacity ?? 1.0,
            initialScaleX: incomingAnimations.transitionInitialScale?.x ?? 1.0,
            initialScaleY: incomingAnimations.transitionInitialScale?.y ?? 1.0,
            initialScaleAnchor: incomingAnimations.transitionInitialScaleAnchor ?? .center,
            initialRotation: incomingAnimations.transitionInitialRotation ?? .zero,
            initialRotationAnchor: incomingAnimations.transitionInitialRotationAnchor ?? .center,
            initialOffset: incomingAnimations.transitionInitialOffset ?? .zero,
            initialBlurRadius: incomingAnimations.transitionInitialBlurRadius ?? .zero,
            onFinished: { navigatorViewModel.screenTransitionDidFinish(screenInstance, side: .incoming) }
        )
        .animatablePropertiesTransition(
            play: $playOutgoingTransition,
            onFinished: { navigatorViewModel.screenTransitionDidFinish(screenInstance, side: .outgoing) }
        )
        .onReceive(screenInstance.$playIncomingTransition) { playIncomingTransition = $0 ?? [] }
        .onReceive(screenInstance.$playOutgoingTransition) { playOutgoingTransition = $0 ?? [] }
        .onAppear {
            navigatorViewModel.screenDidMount(screenInstance)
            screenInstance.consumeFireOnDidAppear()
        }
    }

    @ViewBuilder
    private func templateResolverView(
        _ layout: VC.Screen.LayoutBehaviour,
        screen: VC.Screen
    ) -> some View {
        switch layout {
        case .hero:
            AdaptyUIHeroContainerView(screen: screen)
        case .flat:
            AdaptyUIFlatContainerView(screen: screen)
        case .transparent:
            AdaptyUITransparentContainerView(screen: screen)
        default:
            AdaptyUIScreenLayerView { defaultScreenView(screen) }
        }
    }

    @ViewBuilder
    private func defaultScreenView(_ screen: VC.Screen) -> some View {
        AdaptyUIElementView(
            screen.content,
            screenHolderBuilder: { EmptyView() }
        )
        .background {
            if let background = screen.background {
                AdaptyUIBackgroundElementsView(
                    backgrounds: background,
                    screenHolderBuilder: { EmptyView() }
                )
            }
        }
        .overlay {
            if let overlay = screen.overlay {
                AdaptyUIOverlayElementsView(
                    overlays: overlay,
                    screenHolderBuilder: { EmptyView() }
                )
            }
        }
    }
}

/// Gives a `.default` screen a layer of its own. Without one the screen is flattened into
/// the navigator's display list, and a transition that moves it updates every leaf layer
/// on every frame: on a 120 Hz display that holds the slide at 60 Hz. The other layouts
/// get the layer from the scroll view they are built on; this is the same scroll view
/// with scrolling off.
///
/// The screen keeps the size it had outside the scroll view: its content is offered what
/// the screen holder offers the screen, and the scroll view takes the size the content
/// picks, so a screen that hugs its content (a bottom sheet) is still placed by its
/// navigator. The scroll view proposes no height to its content, so the holder's offer is
/// read by a probe beside it; an axis the holder leaves unspecified gets the screen size.
///
/// Both sizes arrive a layout pass late. The content size is only taken for the offer it
/// was measured with: one measured with the screen size before the probe answered would
/// fix the screen at that size, grow a flexible holder around it, and the probe would then
/// read the grown holder back.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private struct AdaptyUIScreenLayerView<Content: View>: View {
    private struct Measured: Equatable {
        let offered: CGSize
        let size: CGSize
    }

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    @State
    private var offeredSize: CGSize?

    @State
    private var measured: Measured?

    @ViewBuilder let content: Content

    var body: some View {
        let offered = offeredSize ?? screenSize
        let contentSize = measured.flatMap { $0.offered == offeredSize ? $0.size : nil }

        AdaptyUIOfferProbeLayout(fallback: screenSize, contentSize: contentSize) {
            Color.clear
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .onGeometrySizeChange { offeredSize = $0 }

            ScrollView(.vertical) {
                AdaptyUIProposingLayout(size: offered) { content }
                    .background {
                        // A new observer for every offer reports the size even when it
                        // did not change, so a content that hugs is not left unmeasured.
                        Color.clear
                            .onGeometrySizeChange { measured = Measured(offered: offered, size: $0) }
                            .id("\(offered.width)x\(offered.height)")
                    }
            }
            .scrollDisabled(true)
            .scrollIndicators(.hidden)
            .scrollClipDisabled_compatible()
            .ignoresSafeArea()
        }
    }
}

/// Places the first subview, a probe, at the size it is offered itself, falling back to
/// `fallback` on an unspecified axis, and the second one, the scroll view, at the content
/// size around its center, so a content larger than the offer overflows on both sides.
/// The size it reports never exceeds the offer: a size kept from a larger offer would hold
/// a flexible holder at it when the screen shrinks, and the probe would read it back.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private struct AdaptyUIOfferProbeLayout: Layout {
    let fallback: CGSize
    let contentSize: CGSize?

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard let contentSize else { return subviews.last?.sizeThatFits(proposal) ?? .zero }
        return CGSize(
            width: min(contentSize.width, proposal.width ?? contentSize.width),
            height: min(contentSize.height, proposal.height ?? contentSize.height)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        guard let probe = subviews.first, let content = subviews.last else { return }
        let offered = ProposedViewSize(
            width: proposal.width ?? fallback.width,
            height: proposal.height ?? fallback.height
        )
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        probe.place(at: center, anchor: .center, proposal: offered)
        content.place(at: center, anchor: .center, proposal: ProposedViewSize(contentSize ?? bounds.size))
    }
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private extension View {
    /// Keeps the screen's background and overlay, which may reach past its content, from
    /// being cut by the scroll view. iOS 16 has no way to turn the clip off.
    @ViewBuilder
    func scrollClipDisabled_compatible() -> some View {
        if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
            scrollClipDisabled()
        } else {
            self
        }
    }
}

/// Offers its content a fixed size, whatever it is offered itself, and takes the size
/// the content picks.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private struct AdaptyUIProposingLayout: Layout {
    let size: CGSize

    func sizeThatFits(proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        subviews.first?.sizeThatFits(ProposedViewSize(size)) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(size))
    }
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyNavigatorView: View {
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @State
    private var contentAnimations: [VC.Animation] = []

    var body: some View {
        ZStack {
            AdaptyUIAnimatedBackgroundView(
                initialBackground: navigatorViewModel.backgroundSeed,
                defaultColor: .defaultNavigatorColor
            )
            .onTapGesture {
                guard let currentScreen = navigatorViewModel.screens.last else { return }

                if let actions = currentScreen.configuration.screenActions.onOutsideTap {
                    stateViewModel.execute(
                        actions: actions,
                        screen: currentScreen.instance
                    )
                } else if let navigatorActions = navigatorViewModel.navigator.defaultScreenActions.onOutsideTap {
                    stateViewModel.execute(
                        actions: navigatorActions,
                        screen: currentScreen.instance
                    )
                }
            }

            AdaptyUIElementView(
                navigatorViewModel.navigator.content,
                screenHolderBuilder: { AdaptyNavigatorScreensView() }
            )
            .withElementPool(navigatorViewModel.navigator.poolElements)
            .animatablePropertiesTransition(
                play: $contentAnimations,
                initialOpacity: navigatorViewModel.contentSeedOpacity,
                initialOffset: navigatorViewModel.contentSeedOffset,
                onFinished: { navigatorViewModel.contentTransitionDidFinish() }
            )
            .handlingActionURLs(
                stateViewModel: stateViewModel,
                screen: navigatorViewModel.currentScreenInstanceIfSingle
            )
        }
        .environmentObject(navigatorViewModel)
        .environmentObject(navigatorViewModel.eventBus)
        .zIndex(navigatorViewModel.order * 1000.0)
        .onReceive(navigatorViewModel.$contentAnimations) { contentAnimations = $0 ?? [] }
    }
}

/// Reads the navigator's screens in its own body, so a screen change re-renders the
/// holder even when the element views between the navigator and its `screen_holder`
/// are not re-evaluated (iOS 16.1 and earlier skip them).
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private struct AdaptyNavigatorScreensView: View {
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    var body: some View {
        AdaptyUIScreenHolderView(
            screens: navigatorViewModel.screens
        ) { screenInstance in
            AdaptyScreenView(
                screen: screenInstance.configuration
            )
            .handlingActionURLs(
                stateViewModel: stateViewModel,
                screen: screenInstance.instance
            )
            .zIndex(navigatorViewModel.order * 1000.0 + screenInstance.zIndex)
            .environmentObject(screenInstance)
            .environment(\.adaptyScreenInstanceId, screenInstance.instance.id)
        }
    }
}

extension View {
    func overrideOpenUrl(_ handler: @escaping (URL) -> OpenURLAction.Result) -> some View {
        environment(
            \.openURL,
            OpenURLAction(handler: handler)
        )
    }

    /// Runs an action of the configuration opened as a URL in the flow and
    /// passes any other URL to the system, so that `Link` and `openURL` of an
    /// app view inside the flow keep working.
    func handlingActionURLs(
        stateViewModel: AdaptyUIStateViewModel,
        screen: VS.ScreenInstance?
    ) -> some View {
        overrideOpenUrl { url in
            guard url.scheme == VC.Action.scheme else { return .systemAction }
            return stateViewModel.handle(url: url, screen: screen) ? .handled : .discarded
        }
    }
}

// MARK: - Transition Initial Values

private extension [VC.Animation] {
    var transitionInitialOpacity: Double? {
        for animation in self {
            if case let .opacity(range) = animation.kind { return range.start }
        }
        return nil
    }

    var transitionInitialOffset: VC.Offset? {
        for animation in self {
            if case let .offset(range) = animation.kind { return range.start }
        }
        return nil
    }

    var transitionInitialScale: (x: Double, y: Double)? {
        for animation in self {
            if case let .scale(params) = animation.kind {
                return (params.scale.start.x, params.scale.start.y)
            }
        }
        return nil
    }

    var transitionInitialScaleAnchor: UnitPoint? {
        for animation in self {
            if case let .scale(params) = animation.kind { return params.anchor.unitPoint }
        }
        return nil
    }

    var transitionInitialRotation: Angle? {
        for animation in self {
            if case let .rotation(params) = animation.kind { return .degrees(params.angle.start) }
        }
        return nil
    }

    var transitionInitialRotationAnchor: UnitPoint? {
        for animation in self {
            if case let .rotation(params) = animation.kind { return params.anchor.unitPoint }
        }
        return nil
    }

    var transitionInitialBlurRadius: Double? {
        for animation in self {
            if case let .blur(range) = animation.kind { return range.start }
        }
        return nil
    }
}

#endif
