//
//  AdaptyPaywallView_Internal.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyPaywallView_Internal: View {
    private let showDebugOverlay: Bool
    private let products: [AdaptyPaywallProduct]?
    private let introductoryOffersEligibilities: [String: AdaptyEligibility]?
    private let eventsHandler: AdaptyEventsHandler
    private let paywallViewModel: AdaptyPaywallViewModel
    private let productsViewModel: AdaptyProductsViewModel
    private let actionsViewModel: AdaptyUIActionsViewModel
    private let sectionsViewModel: AdaptySectionsViewModel
    private let tagResolverViewModel: AdaptyTagResolverViewModel
    private let timerViewModel: AdaptyTimerViewModel
    private let screensViewModel: AdaptyScreensViewModel

    init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        introductoryOffersEligibilities: [String: AdaptyEligibility]?,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        tagResolver: AdaptyTagResolver?,
        timerResolver: AdaptyTimerResolver,
        showDebugOverlay: Bool,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: @escaping (AdaptyPaywallProduct) -> Void,
        didStartPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didStartRestore: @escaping () -> Void,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool
    ) {
        self.showDebugOverlay = showDebugOverlay
        self.products = products
        self.introductoryOffersEligibilities = introductoryOffersEligibilities

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(configuration.templateId), products: \(products?.count ?? 0)")

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
            didFailLoadingProducts: didFailLoadingProducts
        )

        tagResolverViewModel = AdaptyTagResolverViewModel(tagResolver: tagResolver)
        actionsViewModel = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
        sectionsViewModel = AdaptySectionsViewModel(logId: logId)
        paywallViewModel = AdaptyPaywallViewModel(eventsHandler: eventsHandler,
                                                  paywall: paywall,
                                                  viewConfiguration: configuration)
        productsViewModel = AdaptyProductsViewModel(eventsHandler: eventsHandler,
                                                    paywallViewModel: paywallViewModel,
                                                    products: products,
                                                    introductoryOffersEligibilities: introductoryOffersEligibilities)
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

        productsViewModel.loadProductsIfNeeded()
    }

    var body: some View {
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
        }
    }
}

#endif
