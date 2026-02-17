//
//  AdaptyUIPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIPaywallRendererView: View {
    @EnvironmentObject
    private var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject
    private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject
    private var screensViewModel: AdaptyUIScreensViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ZStack {
                    ForEach(screensViewModel.navigatorsViewModels, id: \.id) { navigator in
                        AdaptyNavigatorView()
                            .environmentObject(navigator)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .clipped()
            .environment(
                \.layoutDirection,
                screensViewModel.isRightToLeft ? .rightToLeft : .leftToRight
            )

            if productsViewModel.purchaseInProgress || productsViewModel.restoreInProgress {
                AdaptyUILoaderView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            paywallViewModel.logShowPaywall()
        }
    }
}

#endif
