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
    private let showsDebugPlaceholders: Bool
    private let safeAreaOverride: EdgeInsets?
    private let interfaceOrientationOverride: VC.Orientation?

    /// Live interface orientation, kept up to date by
    /// `AdaptyUIInterfaceOrientationReader` (unless an override is provided).
    @State private var liveOrientation: VC.Orientation = .platformInitialGuess

    package init(
        showDebugOverlay: Bool,
        showsDebugPlaceholders: Bool,
        safeAreaOverride: EdgeInsets? = nil,
        interfaceOrientationOverride: VC.Orientation? = nil
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.showsDebugPlaceholders = showsDebugPlaceholders
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
                .withInterfaceOrientation(interfaceOrientationOverride ?? liveOrientation)
                .withSafeArea(safeArea)
                .withDebugOverlayEnabled(showDebugOverlay)
                .withShowsDebugPlaceholders(showsDebugPlaceholders)
        }
        .background {
            // Only track live orientation when there is no explicit override.
            if interfaceOrientationOverride == nil {
                AdaptyUIInterfaceOrientationReader(orientation: $liveOrientation)
            }
        }
        .onAppear {
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

#endif
