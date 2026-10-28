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
            if #available(iOS 16.0, *) {
                AdaptyUIScreenLayerView { defaultScreenView(screen) }
            } else {
                defaultScreenView(screen)
            }
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
/// The screen keeps the size it had outside the scroll view: its content is offered the
/// screen size and the scroll view takes the size the content picks, so a screen that
/// hugs its content (a bottom sheet) is still placed by its navigator.
@available(iOS 16.0, *)
private struct AdaptyUIScreenLayerView<Content: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    @State
    private var contentSize: CGSize?

    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(.vertical) {
            AdaptyUIProposingLayout(size: screenSize) { content }
                .onGeometrySizeChange { contentSize = $0 }
        }
        .scrollDisabled(true)
        .scrollIndicatorsHidden_compatible()
        .ignoresSafeArea()
        .frame(width: contentSize?.width, height: contentSize?.height)
    }
}

/// Offers its content a fixed size, whatever it is offered itself, and takes the size
/// the content picks.
@available(iOS 16.0, *)
private struct AdaptyUIProposingLayout: Layout {
    let size: CGSize

    func sizeThatFits(proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        subviews.first?.sizeThatFits(ProposedViewSize(size)) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(size))
    }
}

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
                initialOffset: navigatorViewModel.contentSeedOffset
            )
            .overrideOpenUrl { url in
                stateViewModel.handle(
                    url: url,
                    screen: navigatorViewModel.currentScreenInstanceIfSingle
                ) ? .handled : .discarded
            }
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
            .overrideOpenUrl { url in
                stateViewModel.handle(
                    url: url,
                    screen: screenInstance.instance
                ) ? .handled : .discarded
            }
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
