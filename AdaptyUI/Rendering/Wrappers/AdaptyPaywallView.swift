//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 2/17/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public struct AdaptyPaywallView<AlertItem>: View where AlertItem: Identifiable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let paywallConfiguration: AdaptyUI.PaywallConfiguration

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?
    private let didFailPurchase: ((AdaptyPaywallProduct, AdaptyError) -> Void)?
    private let didFinishWebPaymentNavigation: ((AdaptyPaywallProduct?, AdaptyError?) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: ((AdaptyProfile) -> Void)?
    private let didFailRestore: ((AdaptyError) -> Void)?
    private let didFailRendering: ((AdaptyUIError) -> Void)?
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?
    private let didPartiallyLoadProducts: (([String]) -> Void)?
    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?

    public init(
        paywallConfiguration: AdaptyUI.PaywallConfiguration,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didFinishWebPaymentNavigation: ((AdaptyPaywallProduct?, AdaptyError?) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyUIError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil,
        didPartiallyLoadProducts: (([String]) -> Void)? = nil,
        showAlertItem: Binding<AlertItem?> = Binding<AdaptyIdentifiablePlaceholder?>.constant(nil),
        showAlertBuilder: ((AlertItem) -> Alert)? = nil
    ) {
        self.paywallConfiguration = paywallConfiguration
        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didFailPurchase = didFailPurchase
        self.didFinishWebPaymentNavigation = didFinishWebPaymentNavigation
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRestore = didFailRestore
        self.didFailRendering = didFailRendering
        self.didFailLoadingProducts = didFailLoadingProducts
        self.didPartiallyLoadProducts = didPartiallyLoadProducts
        self.showAlertItem = showAlertItem
        self.showAlertBuilder = showAlertBuilder
    }

    public var body: some View {
        paywallConfiguration.eventsHandler.didAppear = didAppear
        paywallConfiguration.eventsHandler.didDisappear = didDisappear

        paywallConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { action in
            switch action {
            case .close:
                presentationMode.wrappedValue.dismiss()
            case let .openURL(url):
                UIApplication.shared.open(url, options: [:])
            case .custom:
                break
            }
        }

        paywallConfiguration.eventsHandler.didSelectProduct = didSelectProduct ?? { _ in }
        paywallConfiguration.eventsHandler.didStartPurchase = didStartPurchase ?? { _ in }
        paywallConfiguration.eventsHandler.didFinishPurchase = didFinishPurchase ?? { _, res in
            if !res.isPurchaseCancelled {
                presentationMode.wrappedValue.dismiss()
            }
        }
        paywallConfiguration.eventsHandler.didFailPurchase = didFailPurchase
        paywallConfiguration.eventsHandler.didStartRestore = didStartRestore ?? {}
        paywallConfiguration.eventsHandler.didFinishRestore = didFinishRestore
        paywallConfiguration.eventsHandler.didFailRestore = didFailRestore
        paywallConfiguration.eventsHandler.didFailRendering = didFailRendering
        paywallConfiguration.eventsHandler.didFailLoadingProducts = didFailLoadingProducts ?? { _ in true }
        paywallConfiguration.eventsHandler.didPartiallyLoadProducts = didPartiallyLoadProducts

        paywallConfiguration.eventsHandler.didFinishWebPaymentNavigation = didFinishWebPaymentNavigation ?? { _, _ in }

        return AdaptyPaywallView_Internal(
            showDebugOverlay: false,
            showAlertItem: showAlertItem,
            showAlertBuilder: showAlertBuilder
        )
        .environmentObject(paywallConfiguration.eventsHandler)
        .environmentObject(paywallConfiguration.paywallViewModel)
        .environmentObject(paywallConfiguration.productsViewModel)
        .environmentObject(paywallConfiguration.actionsViewModel)
        .environmentObject(paywallConfiguration.sectionsViewModel)
        .environmentObject(paywallConfiguration.tagResolverViewModel)
        .environmentObject(paywallConfiguration.timerViewModel)
        .environmentObject(paywallConfiguration.screensViewModel)
        .environmentObject(paywallConfiguration.assetsViewModel)
        .onAppear {
            paywallConfiguration.reportOnAppear()
        }
    }
}

#endif
