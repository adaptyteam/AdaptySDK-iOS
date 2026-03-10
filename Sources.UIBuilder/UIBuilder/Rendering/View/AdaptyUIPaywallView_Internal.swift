//
//  AdaptyUIPaywallView_Internal.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
package struct AdaptyUIPaywallView_Internal: View {
    @EnvironmentObject private var productsViewModel: AdaptyUIProductsViewModel

    private let showDebugOverlay: Bool
    private let displayMissingTags: Bool
    private let safeAreaOverride: EdgeInsets?

    package init(
        showDebugOverlay: Bool,
        displayMissingTags: Bool,
        safeAreaOverride: EdgeInsets? = nil
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.displayMissingTags = displayMissingTags
        self.safeAreaOverride = safeAreaOverride
    }

    package var body: some View {
        GeometryReader { proxy in
            let safeArea = safeAreaOverride ?? proxy.safeAreaInsets
            AdaptyUIPaywallRendererView()
                .withScreenSize(
                    CGSize(
                        width: proxy.size.width + safeArea.leading + safeArea.trailing,
                        height: proxy.size.height + safeArea.top + safeArea.bottom
                    )
                )
                .withSafeArea(safeArea)
                .withDebugOverlayEnabled(showDebugOverlay)
                .withDisplayMissingTags(displayMissingTags)
        }
        .onAppear {
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

#endif
