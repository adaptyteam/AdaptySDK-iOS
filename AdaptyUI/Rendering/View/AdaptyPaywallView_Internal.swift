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
    private let showDebugOverlay: Bool
    private let products: [AdaptyPaywallProduct]?
    private let eventsHandler: AdaptyEventsHandler
    
    private let paywallViewModel: AdaptyPaywallViewModel
    private let productsViewModel: AdaptyProductsViewModel
    private let actionsViewModel: AdaptyUIActionsViewModel
    private let sectionsViewModel: AdaptySectionsViewModel
    private let tagResolverViewModel: AdaptyTagResolverViewModel
    private let timerViewModel: AdaptyTimerViewModel
    private let screensViewModel: AdaptyScreensViewModel
    private let videoViewModel: AdaptyVideoViewModel

    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?

    init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        observerModeResolver: AdaptyObserverModeResolver?,
        tagResolver: AdaptyTagResolver?,
        timerResolver: AdaptyTimerResolver,
        showDebugOverlay: Bool,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: @escaping (AdaptyPaywallProductWithoutDeterminingOffer) -> Void,
        didStartPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didStartRestore: @escaping () -> Void,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool,
        didPartiallyLoadProducts: @escaping ([String]) -> Void,
        showAlertItem: Binding<AlertItem?> = Binding<AdaptyIdentifiablePlaceholder?>.constant(nil),
        showAlertBuilder: ((AlertItem) -> Alert)? = nil
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.products = products

        self.showAlertItem = showAlertItem
        self.showAlertBuilder = showAlertBuilder

        Log.ui.verbose("#\(logId)# init template: \(configuration.templateId), products: \(products?.count ?? 0)")

        eventsHandler = AdaptyEventsHandler(
            logId: logId,
            didPerformAction: didPerformAction,
            didSelectProduct: didSelectProduct,
            didStartPurchase: didStartPurchase,
            didFinishPurchase: didFinishPurchase,
            didFailPurchase: didFailPurchase,
            didCancelPurchase: didCancelPurchase,
            didStartRestore: didStartRestore,
            didFinishRestore: didFinishRestore,
            didFailRestore: didFailRestore,
            didFailRendering: didFailRendering,
            didFailLoadingProducts: didFailLoadingProducts,
            didPartiallyLoadProducts: didPartiallyLoadProducts
        )

        tagResolverViewModel = AdaptyTagResolverViewModel(tagResolver: tagResolver)
        actionsViewModel = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
        sectionsViewModel = AdaptySectionsViewModel(logId: logId)
        paywallViewModel = AdaptyPaywallViewModel(eventsHandler: eventsHandler,
                                                  paywall: paywall,
                                                  viewConfiguration: configuration)
        productsViewModel = AdaptyProductsViewModel(
            eventsHandler: eventsHandler,
            paywallViewModel: paywallViewModel,
            products: products,
            observerModeResolver: observerModeResolver
        )
        screensViewModel = AdaptyScreensViewModel(eventsHandler: eventsHandler,
                                                  viewConfiguration: configuration)
        timerViewModel = AdaptyTimerViewModel(
            timerResolver: timerResolver,
            paywallViewModel: paywallViewModel,
            productsViewModel: productsViewModel,
            actionsViewModel: actionsViewModel,
            sectionsViewModel: sectionsViewModel,
            screensViewModel: screensViewModel
        )
        
        videoViewModel = AdaptyVideoViewModel(eventsHandler: eventsHandler)

        productsViewModel.loadProductsIfNeeded()
    }

    @ViewBuilder
    private var paywallBody: some View {
        GeometryReader { proxy in
            AdaptyPaywallRendererView()
                .withScreenSize(
                    CGSize(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                           height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
                )
                .withSafeArea(proxy.safeAreaInsets)
                .withDebugOverlayEnabled(showDebugOverlay)
                .environmentObject(paywallViewModel)
                .environmentObject(productsViewModel)
                .environmentObject(actionsViewModel)
                .environmentObject(sectionsViewModel)
                .environmentObject(tagResolverViewModel)
                .environmentObject(timerViewModel)
                .environmentObject(screensViewModel)
                .environmentObject(videoViewModel)
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
