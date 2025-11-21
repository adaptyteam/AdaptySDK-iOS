//
//  AdaptyUIPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension VC {
    enum Template: String {
        case basic
        case flat
        case transparent
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

    public var body: some View {
        let viewConfiguration = paywallViewModel.viewConfiguration

        if let template = VC.Template(rawValue: viewConfiguration.templateId) {
            ZStack(alignment: .bottom) {
                templateResolverView(template, screen: viewConfiguration.screen)
                    .staticBackground(viewConfiguration.screen.background)

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
                        with: .unsupportedTemplate(viewConfiguration.templateId)
                    )
                }
        }
    }
}

#endif
