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
            screenInstance.configuration.templateId,
            screen: screenInstance.configuration
        )
        .staticBackground(
            screenInstance.configuration.background,
            defaultValue: VC.Asset.defaultScreenBackground
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
        _ templateId: String,
        screen: VC.Screen
    ) -> some View {
        switch templateId {
        case VC.templateIdBasic:
            AdaptyUIBasicContainerView(screen: screen)
        case VC.templateIdFlat:
            AdaptyUIFlatContainerView(screen: screen)
        case VC.templateIdTransparent:
            AdaptyUITransparentContainerView(screen: screen)
        default:
            // TODO: x extract
            Rectangle()
                .hidden()
                .onAppear {
                    paywallViewModel.reportDidFailRendering(
                        with: .unsupportedTemplate(templateId)
                    )
                }
        }
    }
}

struct AdaptyNavigatorView: View {
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel

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
                initialOpacity: navigatorViewModel.appearTransition?.initialContentOpacity ?? 1.0
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
