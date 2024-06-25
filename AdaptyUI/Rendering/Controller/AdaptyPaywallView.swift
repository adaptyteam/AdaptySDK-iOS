//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyPaywallView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let paywall: AdaptyPaywall
    private let products: [AdaptyPaywallProduct]?
    private let configuration: AdaptyUI.LocalizedViewConfiguration
    private let eventsHandler: AdaptyEventsHandler
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
        configuration: AdaptyUI.LocalizedViewConfiguration,
        tagResolver: AdaptyTagResolver?,
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
        self.paywall = paywall
        self.products = products
        self.configuration = configuration

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
        productsViewModel = AdaptyProductsViewModel(eventsHandler: eventsHandler,
                                                    paywall: paywall,
                                                    products: products,
                                                    viewConfiguration: configuration)
        screensViewModel = AdaptyScreensViewModel(eventsHandler: eventsHandler,
                                                  viewConfiguration: configuration)
        timerViewModel = AdaptyTimerViewModel(
            productsViewModel: productsViewModel,
            actionsViewModel: actionsViewModel,
            sectionsViewModel: sectionsViewModel,
            screensViewModel: screensViewModel
        )
        
        productsViewModel.loadProductsIfNeeded()
    }

    var body: some View {
        GeometryReader { proxy in
            AdaptyPaywallRendererView(viewConfiguration: configuration)
                .withScreenSize(proxy.size)
                .withSafeArea(proxy.safeAreaInsets)
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
