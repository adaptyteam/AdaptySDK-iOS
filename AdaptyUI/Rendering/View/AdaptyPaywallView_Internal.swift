//
//  AdaptyPaywallView_Internal.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

public struct AdaptyIdentifiablePlaceholder: Identifiable {
    public var id: String { "placeholder" }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyPaywallView_Internal<AlertItem>: View where AlertItem: Identifiable {
    @EnvironmentObject private var productsViewModel: AdaptyProductsViewModel

    private let showDebugOverlay: Bool
    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?

    init(
        showDebugOverlay: Bool,
        showAlertItem: Binding<AlertItem?> = Binding<AdaptyIdentifiablePlaceholder?>.constant(nil),
        showAlertBuilder: ((AlertItem) -> Alert)? = nil
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.showAlertItem = showAlertItem
        self.showAlertBuilder = showAlertBuilder
    }

    @ViewBuilder
    private var paywallBody: some View {
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

    var body: some View {
        if let showAlertBuilder {
            paywallBody
                .alert(item: showAlertItem) { showAlertBuilder($0) }
        } else {
            paywallBody
        }
    }
}

#endif
