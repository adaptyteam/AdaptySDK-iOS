//
//  AdaptyPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUICore {
    enum Template: String {
        case basic
        case flat
        case transparent
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyPaywallRendererView: View {
    @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    @ViewBuilder
    private func templateResolverView(_ template: AdaptyUICore.Template, screen: AdaptyUICore.Screen) -> some View {
        switch template {
        case .basic:
            AdaptyUIBasicContainerView(screen: screen)
        case .flat:
            AdaptyUIFlatContainerView(screen: screen)
        case .transparent:
            AdaptyUITransparentContainerView(screen: screen)
        }
    }

    public var body: some View {
        let viewConfiguration = paywallViewModel.viewConfiguration

        if let template = AdaptyUICore.Template(rawValue: viewConfiguration.templateId) {
            ZStack {
                templateResolverView(template, screen: viewConfiguration.screen)
                    .decorate(with: viewConfiguration.screen.background)

                if productsViewModel.purchaseInProgress || productsViewModel.restoreInProgress {
                    AdaptyUILoaderView()
                        .transition(.opacity)
                }
            }
            .overlay {
                ZStack(alignment: .bottom) {
                    Color.black
                        .opacity(!screensViewModel.presentedScreensStack.isEmpty ? 0.4 : 0.0)
                        .onTapGesture {
                            withAnimation {
                                screensViewModel.dismissTopScreen()
                            }
                        }
                    
                    ForEach(screensViewModel.presentedScreensStack) { bottomSheet in
                        AdaptyUIBottomSheetView(bottomSheet)
                    }
                }
                .ignoresSafeArea()
            }
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
            .onAppear {
                paywallViewModel.logShowPaywall()
            }
        } else {
            EmptyView()
                .onAppear {
                    paywallViewModel.eventsHandler.event_didFailRendering(
                        with: .unsupportedTemplate(viewConfiguration.templateId)
                    )
                }
        }
    }
}

#endif
