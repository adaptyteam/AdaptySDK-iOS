//
//  AdaptyPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyPaywallRendererView: View {
    @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    public var body: some View {
        let viewConfiguration = paywallViewModel.viewConfiguration
        
        if let template = AdaptyUI.Template(rawValue: viewConfiguration.templateId) {
            ZStack {
                // TODO: consider move logic here
                AdaptyUITemplateResolverView(
                    template: template,
                    screen: viewConfiguration.screen
                )
                .decorate(with: viewConfiguration.screen.background)

                ForEach(screensViewModel.presentedScreensStack) { bottomSheet in
                    AdaptyUIBottomSheetView(bottomSheet)
                }
                
                if productsViewModel.purchaseInProgress || productsViewModel.restoreInProgress {
                    AdaptyUILoaderView()
                        .transition(.opacity)
                }
            }
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
            .onAppear {
                paywallViewModel.logShowPaywall()
            }
        } else {
            AdaptyUIRenderingErrorView(text: "Wrong templateId: \(viewConfiguration.templateId)", forcePresent: true)
        }
    }
}

#endif
