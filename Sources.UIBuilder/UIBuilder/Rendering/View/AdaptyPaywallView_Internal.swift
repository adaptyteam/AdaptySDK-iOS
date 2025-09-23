//
//  AdaptyPaywallView_Internal.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package struct AdaptyPaywallView_Internal: View {
    @EnvironmentObject private var productsViewModel: AdaptyProductsViewModel

    private let showDebugOverlay: Bool

    package init(
        showDebugOverlay: Bool,
    ) {
        self.showDebugOverlay = showDebugOverlay
    }

    package var body: some View {
        GeometryReader { proxy in
            AdaptyPaywallRendererView()
                .withScreenSize(
                    CGSize(
                        width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                        height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                    )
                )
                .withSafeArea(proxy.safeAreaInsets)
                .withDebugOverlayEnabled(showDebugOverlay)
        }
        .onAppear {
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

#endif
