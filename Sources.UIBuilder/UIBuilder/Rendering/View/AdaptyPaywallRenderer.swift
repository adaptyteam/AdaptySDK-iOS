//
//  AdaptyUIPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import SwiftUI

package extension VC {
    enum Template_legacy: String {
        case basic
        case flat
        case transparent
    }
}

struct AdaptyUIPaywallRendererView: View {
    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel

    @ViewBuilder
    private func templateResolverView(
        _ template: VC.Template_legacy,
        screen: VC.Screen
    ) -> some View {
        switch template {
        case .basic:
            AdaptyUIBasicContainerView(screen: screen)
        case .flat:
            AdaptyUIFlatContainerView(screen: screen)
        case .transparent:
            AdaptyUITransparentContainerView(screen: screen)
        }
    }

    var body: some View {
        let viewConfiguration = paywallViewModel.viewConfiguration

        ZStack(alignment: .bottom) {
            AdaptyNavigationView { screenInstance in
                templateResolverView(
                    screenInstance.template,
                    screen: screenInstance.configuration
                )
                .staticBackground(
                    screenInstance.configuration.background,
                    defaultValue: .defaultScreenBackground
                )
                .withScreenInstance(screenInstance.instance)
            }

            Color.black
                .opacity(!screensViewModel.presentedScreensStack.isEmpty ? 0.4 : 0.0)
                .onTapGesture {
                    screensViewModel.dismissTopScreen()
                }

            // TODO: x deprecated, remove
            ForEach(screensViewModel.bottomSheetsViewModels, id: \.id) { vm in
                AdaptyUIBottomSheetView()
                    .environmentObject(vm)
            }

            if productsViewModel.purchaseInProgress || productsViewModel.restoreInProgress {
                AdaptyUILoaderView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        // TODO: x remove?
        .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
        .onAppear {
            paywallViewModel.logShowPaywall()
        }
    }
}

#endif
