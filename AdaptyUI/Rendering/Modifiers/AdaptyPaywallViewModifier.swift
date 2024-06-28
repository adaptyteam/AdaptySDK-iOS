//
//  AdaptyPaywallViewModifier.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyPaywallViewModifier: ViewModifier {
    private let logId = AdaptyUI.generateLogId()

    var isPresented: Binding<Bool>
    var fullScreen: Bool

    var paywall: AdaptyPaywall
    var products: [AdaptyPaywallProduct]?
    var introductoryOffersEligibilities: [String: AdaptyEligibility]?
    var configuration: AdaptyUI.LocalizedViewConfiguration
    var tagResolver: AdaptyTagResolver?

    var didPerformAction: ((AdaptyUI.UserAction) -> Void)?
    var didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
    var didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    var didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)?
    var didFailPurchase: (AdaptyPaywallProduct, AdaptyError) -> Void
    var didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    var didStartRestore: (() -> Void)?
    var didFinishRestore: (AdaptyProfile) -> Void
    var didFailRestore: (AdaptyError) -> Void
    var didFailRendering: ((AdaptyError) -> Void)?
    var didFailLoadingProducts: (AdaptyError) -> Bool

    func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(
                    isPresented: isPresented,
                    content: {
                        paywallView
                            .ignoresSafeArea()
                    }
                )
        } else {
            content
                .sheet(
                    isPresented: isPresented,
                    content: {
                        paywallView
                    }
                )
        }
    }

    private var paywallView: some View {
        AdaptyPaywallView(
            logId: logId,
            paywall: paywall,
            products: products,
            introductoryOffersEligibilities: introductoryOffersEligibilities,
            configuration: configuration,
            tagResolver: tagResolver,
            showDebugOverlay: false,
            didPerformAction: { action in
                if let didPerformAction {
                    didPerformAction(action)
                } else {
                    handleDidPerformAction(action)
                }
            },
            didSelectProduct: { product in
                if let didSelectProduct {
                    didSelectProduct(product)
                }
            },
            didStartPurchase: { product in
                if let didStartPurchase {
                    didStartPurchase(product)
                }
            },
            didFinishPurchase: { product, info in
                if let didFinishPurchase {
                    didFinishPurchase(product, info)
                }
            },
            didFailPurchase: didFailPurchase,
            didCancelPurchase: { product in
                if let didCancelPurchase {
                    didCancelPurchase(product)
                }
            },
            didStartRestore: didStartRestore ?? {},
            didFinishRestore: didFinishRestore,
            didFailRestore: didFailRestore,
            didFailRendering: { error in
                if let didFailRendering {
                    didFailRendering(error)
                } else {
                    handleDidFailRendering()
                }
            },
            didFailLoadingProducts: didFailLoadingProducts ?? { _ in true }
        )
    }

    // MARK: Default Events Handlers

    private func handleDidPerformAction(_ action: AdaptyUI.UserAction) {
        switch action {
        case .close:
            isPresented.wrappedValue = false
        case let .openURL(url):
            UIApplication.shared.open(url, options: [:])
        case .custom:
            break
        }
    }

    private func handleDidFailRendering() {
        isPresented.wrappedValue = false
    }
}

#endif
