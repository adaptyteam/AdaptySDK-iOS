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
        .animatablePropertiesTransition(
            play: $playIncomingTransition,
            initialOpacity: incomingAnimations.transitionInitialOpacity ?? 1.0,
            initialScaleX: incomingAnimations.transitionInitialScale?.x ?? 1.0,
            initialScaleY: incomingAnimations.transitionInitialScale?.y ?? 1.0,
            initialScaleAnchor: incomingAnimations.transitionInitialScaleAnchor ?? .center,
            initialRotation: incomingAnimations.transitionInitialRotation ?? .zero,
            initialRotationAnchor: incomingAnimations.transitionInitialRotationAnchor ?? .center,
            initialOffset: incomingAnimations.transitionInitialOffset ?? .zero,
            initialBlurRadius: incomingAnimations.transitionInitialBlurRadius ?? .zero
        )
        .animatablePropertiesTransition(
            play: $playOutgoingTransition
        )
        .onReceive(screenInstance.$playIncomingTransition) { playIncomingTransition = $0 ?? [] }
        .onReceive(screenInstance.$playOutgoingTransition) { playOutgoingTransition = $0 ?? [] }
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
            AdaptyUIElementView(
                screen.content,
                screenHolderBuilder: { EmptyView() } // TODO: x check
            )
        }
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
                initialBackground: navigatorViewModel.initialBackground,
                defaultColor: .defaultNavigatorColor
            )
            .onTapGesture {
                guard let currentScreen = navigatorViewModel.screens.last else { return }

                if let navigatorActions = navigatorViewModel.navigator.defaultScreenActions.onOutsideTap {
                    stateViewModel.execute(
                        actions: navigatorActions,
                        screen: currentScreen.instance
                    )
                } else if let actions = currentScreen.configuration.screenActions.onOutsideTap {
                    stateViewModel.execute(
                        actions: actions,
                        screen: currentScreen.instance
                    )
                }
            }

            AdaptyUIElementView(
                navigatorViewModel.navigator.content,
                screenHolderBuilder: {
                    ZStack {
                        ForEach(navigatorViewModel.screens, id: \.id) { screenInstance in
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
            )
            .animatablePropertiesTransition(
                play: $contentAnimations,
                initialOpacity: navigatorViewModel.appearTransition?.initialContentOpacity ?? 1.0,
                initialOffset: navigatorViewModel.appearTransition?.initialContentOffset ?? .zero
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
            if case let .opacity(_, range) = animation { return range.start }
        }
        return nil
    }

    var transitionInitialOffset: VC.Offset? {
        for animation in self {
            if case let .offset(_, range) = animation { return range.start }
        }
        return nil
    }

    var transitionInitialScale: (x: Double, y: Double)? {
        for animation in self {
            if case let .scale(_, params) = animation {
                return (params.scale.start.x, params.scale.start.y)
            }
        }
        return nil
    }

    var transitionInitialScaleAnchor: UnitPoint? {
        for animation in self {
            if case let .scale(_, params) = animation { return params.anchor.unitPoint }
        }
        return nil
    }

    var transitionInitialRotation: Angle? {
        for animation in self {
            if case let .rotation(_, params) = animation { return .degrees(params.angle.start) }
        }
        return nil
    }

    var transitionInitialRotationAnchor: UnitPoint? {
        for animation in self {
            if case let .rotation(_, params) = animation { return params.anchor.unitPoint }
        }
        return nil
    }

    var transitionInitialBlurRadius: Double? {
        for animation in self {
            if case let .blur(_, range) = animation { return range.start }
        }
        return nil
    }
}

#endif

