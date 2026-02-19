//
//  AdaptyUIPaywallView_Internal.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 17.06.2024.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package struct AdaptyUIPaywallView_Internal: View {
    @EnvironmentObject private var productsViewModel: AdaptyUIProductsViewModel
    @State private var macWindowMetrics: AdaptyUIWindowMetrics?

    private let showDebugOverlay: Bool

    package init(
        showDebugOverlay: Bool
    ) {
        self.showDebugOverlay = showDebugOverlay
    }

    package var body: some View {
        GeometryReader { proxy in
            let resolvedSafeArea = SystemConstantsManager.resolveSafeAreaInsets(
                geometryInsets: proxy.safeAreaInsets,
                windowMetrics: macWindowMetrics
            )
            let resolvedScreenSize = SystemConstantsManager.resolveScreenSize(
                geometrySize: proxy.size,
                resolvedSafeArea: resolvedSafeArea,
                windowMetrics: macWindowMetrics
            )

            AdaptyUIPaywallRendererView()
                .withScreenSize(resolvedScreenSize)
                .withSafeArea(resolvedSafeArea)
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
                .background(
                    MacOSWindowMetricsReader(metrics: $macWindowMetrics)
                        .frame(width: 0, height: 0)
                )
#endif
                .withDebugOverlayEnabled(showDebugOverlay)
        }
        .onAppear {
            productsViewModel.loadProductsIfNeeded()
        }
    }
}
