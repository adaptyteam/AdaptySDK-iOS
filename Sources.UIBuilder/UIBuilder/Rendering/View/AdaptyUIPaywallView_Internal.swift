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
    private let interfaceOrientationOverride: VC.Orientation?

    package init(
        showDebugOverlay: Bool,
        displayMissingTags: Bool,
        safeAreaOverride: EdgeInsets? = nil,
        interfaceOrientationOverride: VC.Orientation? = nil
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.displayMissingTags = displayMissingTags
        self.safeAreaOverride = safeAreaOverride
        self.interfaceOrientationOverride = interfaceOrientationOverride
    }

    package var body: some View {
        GeometryReader { proxy in
            let safeArea = safeAreaOverride ?? proxy.safeAreaInsets
            AdaptyUIFlowRendererView()
                .withScreenSize(
                    CGSize(
                        width: proxy.size.width + safeArea.leading + safeArea.trailing,
                        height: proxy.size.height + safeArea.top + safeArea.bottom
                    )
                )
                .withInterfaceOrientation(interfaceOrientationOverride ?? .currentInterface)
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
