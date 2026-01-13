//
//  AdaptyUIPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import SwiftUI

package extension VC {
    enum Template: String {
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
    private func templateResolverView(_ template: VC.Template, screen: VC.Screen) -> some View {
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

        if let template = VC.Template(rawValue: viewConfiguration.deprecated_defaultScreen.templateId) {
            ZStack(alignment: .bottom) {
                templateResolverView(template, screen: viewConfiguration.deprecated_defaultScreen)
                    .staticBackground(
                        viewConfiguration.deprecated_defaultScreen.background,
                        defaultValue: .defaultScreenBackground
                    )
                Color.black
                    .opacity(!screensViewModel.presentedScreensStack.isEmpty ? 0.4 : 0.0)
                    .onTapGesture {
                        screensViewModel.dismissTopScreen()
                    }

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
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
            .onAppear {
                paywallViewModel.logShowPaywall()
            }
        } else {
            EmptyView()
                .onAppear {
                    paywallViewModel.reportDidFailRendering(
                        with: .unsupportedTemplate(viewConfiguration.deprecated_defaultScreen.templateId)
                    )
                }
        }
    }
}

#endif
