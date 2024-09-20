//
//  AdaptyPaywallView+Public.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 20.09.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
public struct AdaptyPaywallView: View {
    private let paywall: AdaptyPaywall
    private let products: [AdaptyPaywallProduct]?
    private let introductoryOffersEligibilities: [String: AdaptyEligibility]?
    private let configuration: AdaptyUI.LocalizedViewConfiguration
    private let observerModeResolver: AdaptyObserverModeResolver?
    private let tagResolver: AdaptyTagResolver?
    private let timerResolver: AdaptyTimerResolver

    @ObservedObject var actionsHolder: AdaptyPaywallViewActionsHolder

    public init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        introductoryOffersEligibilities: [String: AdaptyEligibility]? = nil,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil
    ) {
        self._actionsHolder = .init(wrappedValue: .init())

        self.paywall = paywall
        self.products = products
        self.introductoryOffersEligibilities = introductoryOffersEligibilities
        self.configuration = configuration
        self.observerModeResolver = observerModeResolver
        self.tagResolver = tagResolver
        self.timerResolver = timerResolver ?? AdaptyUIDefaultTimerResolver()
    }

    public var body: some View {
        AdaptyPaywallView_Internal(
            logId: AdaptyUI.generateLogId(),
            paywall: self.paywall,
            products: self.products,
            introductoryOffersEligibilities: self.introductoryOffersEligibilities,
            configuration: self.configuration,
            observerModeResolver: self.observerModeResolver,
            tagResolver: self.tagResolver,
            timerResolver: self.timerResolver,
            showDebugOverlay: false,
            didPerformAction: { self.actionsHolder.didPerformAction($0) },
            didSelectProduct: { self.actionsHolder.didSelectProduct($0) },
            didStartPurchase: { self.actionsHolder.didStartPurchase($0) },
            didFinishPurchase: { self.actionsHolder.didFinishPurchase($0, $1) },
            didFailPurchase: { self.actionsHolder.didFailPurchase($0, $1) },
            didCancelPurchase: { self.actionsHolder.didCancelPurchase($0) },
            didStartRestore: { self.actionsHolder.didStartRestore() },
            didFinishRestore: { self.actionsHolder.didFinishRestore($0) },
            didFailRestore: { self.actionsHolder.didFailRestore($0) },
            didFailRendering: { self.actionsHolder.didFailRendering($0) },
            didFailLoadingProducts: { error in
                self.actionsHolder.didFailLoadingProducts(error)
                return false
            }
        )
        .preference(key: PreferenceKeys.OnPaywallDidPerformAction.self,
                    value: self.actionsHolder.didPerformActionValue)
        .preference(key: PreferenceKeys.OnPaywallDidSelectProduct.self,
                    value: self.actionsHolder.didSelectProductValue)
        .preference(key: PreferenceKeys.OnPaywallDidStartPurchase.self,
                    value: self.actionsHolder.didStartPurchaseValue)
        .preference(key: PreferenceKeys.OnPaywallDidFinishPurchase.self,
                    value: self.actionsHolder.didFinishPurchaseValue)
        .preference(key: PreferenceKeys.OnPaywallDidCancelPurchase.self,
                    value: self.actionsHolder.didCancelPurchaseValue)
        .preference(key: PreferenceKeys.OnPaywallDidStartRestore.self,
                    value: self.actionsHolder.didStartRestoreValue)
        .preference(key: PreferenceKeys.OnPaywallDidStartRestore.self,
                    value: self.actionsHolder.didStartRestoreValue)
        .preference(key: PreferenceKeys.OnPaywallDidFinishRestore.self,
                    value: self.actionsHolder.didFinishRestoreValue)
        .preference(key: PreferenceKeys.OnPaywallDidFailRestore.self,
                    value: self.actionsHolder.didFailRestoreValue)
        .preference(key: PreferenceKeys.OnPaywallDidFailRendering.self,
                    value: self.actionsHolder.didFailRenderingValue)
        .preference(key: PreferenceKeys.OnPaywallDidFailLoadingProducts.self,
                    value: self.actionsHolder.didFailLoadingProductsValue)
    }
}

// MARK: - View Extensions

@available(iOS 15.0, *)
public extension View {
    func onPaywallDidPerformAction(_ callback: @escaping (AdaptyUI.Action) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidPerformAction { callback($0) }
        )
    }

    func onPaywallDidSelectProduct(_ callback: @escaping (AdaptyPaywallProduct) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidSelectProduct { callback($0) }
        )
    }

    func onPaywallDidStartPurchase(_ callback: @escaping (AdaptyPaywallProduct) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidStartPurchase { callback($0) }
        )
    }

    func onPaywallDidFinishPurchase(_ callback: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFinishPurchase { callback($0.product, $0.info) }
        )
    }

    func onPaywallDidFailPurchase(_ callback: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFailPurchase { callback($0.product, $0.error) }
        )
    }

    func onPaywallDidCancelPurchase(_ callback: @escaping (AdaptyPaywallProduct) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidCancelPurchase { callback($0) }
        )
    }

    func onPaywallDidStartRestore(_ callback: @escaping () -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidStartRestore { callback() }
        )
    }

    func onPaywallDidFinishRestore(_ callback: @escaping (AdaptyProfile) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFinishRestore { callback($0) }
        )
    }

    func onPaywallDidFailRestore(_ callback: @escaping (AdaptyError) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFailRestore { callback($0) }
        )
    }

    func onPaywallDidFailRendering(_ callback: @escaping (AdaptyError) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFailRendering { callback($0) }
        )
    }

    func onPaywallDidFailLoadingProducts(_ callback: @escaping (AdaptyError) -> Void) -> some View {
        self.modifier(
            Modifier.OnPaywallDidFailLoadingProducts { callback($0) }
        )
    }
}

#endif
