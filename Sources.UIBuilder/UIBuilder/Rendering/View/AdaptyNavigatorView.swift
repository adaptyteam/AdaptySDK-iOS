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

    @ViewBuilder
    private func screenBuilder(screenInstance: AdaptyUIScreenInstance) -> some View {}

    var body: some View {
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
        .staticBackground(
            navigatorViewModel.navigator.background,
            defaultValue: VC.Asset.defaultNavigatorBackground
        )
        .offset(navigatorViewModel.offset)
        .opacity(navigatorViewModel.opacity)
        .zIndex(navigatorViewModel.order * 1000.0)
        .onAppear {
            navigatorViewModel.reportOnAppear()
        }
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
