//
//  AdaptyNavigatorView.swift
//  Adapty
//
//  Created by Alex Goncharov on 23/01/2026.
//

#if canImport(UIKit)

import SwiftUI

package extension VC {
    static let templateIdBasic = "basic"
    static let templateIdFlat = "flat"
    static let templateIdTransparent = "transparent"
}

struct AdaptyScreenView: View {
    var screen: VC.Screen

    @EnvironmentObject
    private var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel
    @EnvironmentObject
    private var screenInstance: AdaptyUIScreenInstance

    @State
    private var playIncomingTransition: [VC.Animation] = []

    @State
    private var playOutgoingTransition: [VC.Animation] = []

    var body: some View {
        templateResolverView(
            screenInstance.configuration.layoutBehaviour,
            screen: screenInstance.configuration
        )
        .withScreenInstance(screenInstance.instance)
        .animatablePropertiesTransition(
            play: $playIncomingTransition
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
            AdaptyUIBasicContainerView(screen: screen)
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

    @State private var backgroundAnimation: VC.Animation.Background?
    @State private var contentAnimations: [VC.Animation] = []

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .animatedBackground(
                    play: $backgroundAnimation,
                    initialBackground: navigatorViewModel.appearTransition?.background?.initialBackground,
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
                            .zIndex(navigatorViewModel.order * 1000.0 + screenInstance.zIndex)
                            .environmentObject(screenInstance)
                        }
                    }
                }
            )
            .animatablePropertiesTransition(
                play: $contentAnimations,
                initialOpacity: navigatorViewModel.appearTransition?.initialContentOpacity ?? 1.0,
                initialOffset: navigatorViewModel.appearTransition?.initialContentOffset ?? .zero
            )
        }
        .zIndex(navigatorViewModel.order * 1000.0)
        .onReceive(navigatorViewModel.$backgroundAnimation) { backgroundAnimation = $0 }
        .onReceive(navigatorViewModel.$contentAnimations) { contentAnimations = $0 ?? [] }
    }
}

// TODO: x zIndex exeperiments

// #Preview {
//    ZStack {
//        Rectangle()
//            .fill(Color.red)
//            .frame(width: 100, height: 100, alignment: .center)
//            .offset(x: -25, y: -25)
//
//        Rectangle()
//            .fill(Color.blue)
//            .frame(width: 100, height: 100, alignment: .center)
//            .offset(x: 25, y: 25)
//    }
// }

#endif
