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

    var viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    init(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) {
        self.viewConfiguration = viewConfiguration
    }

    public var body: some View {
        if let template = AdaptyUI.Template(rawValue: viewConfiguration.templateId) {
            AdaptyUITemplateResolverView(
                template: template,
                screen: viewConfiguration.screen,
                isRightToLeft: viewConfiguration.isRightToLeft
            )
            .decorate(with: viewConfiguration.screen.background)
            .onAppear {
                productsViewModel.logShowPaywall()
            }
        } else {
            AdaptyUIRenderingErrorView(text: "Wrong templateId: \(viewConfiguration.templateId)", forcePresent: true)
        }
    }
}

#endif
