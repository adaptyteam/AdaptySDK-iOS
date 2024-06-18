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
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    var viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    init(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) {
        self.viewConfiguration = viewConfiguration
    }

    public var body: some View {
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
            }
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
            .onAppear {
                productsViewModel.logShowPaywall()
            }
        } else {
            AdaptyUIRenderingErrorView(text: "Wrong templateId: \(viewConfiguration.templateId)", forcePresent: true)
        }
    }
}

#endif
