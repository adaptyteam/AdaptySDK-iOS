//
//  AdaptyPaywallView.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
public struct AdaptyPaywallViewModifier: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let logId: String
    private let paywall: AdaptyPaywall
    private let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    private let products: [AdaptyPaywallProduct]?
    private let introductoryOffersEligibilities: [String: AdaptyEligibility]?
    private let tagResolver: AdaptyTagResolver?
    private let timerResolver: AdaptyTimerResolver?

    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)?
    private let didFailPurchase: (AdaptyPaywallProduct, AdaptyError) -> Void
    private let didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: (AdaptyProfile) -> Void
    private let didFailRestore: (AdaptyError) -> Void
    private let didFailRendering: (AdaptyError) -> Void
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?

    public init(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywall: AdaptyPaywall,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        products: [AdaptyPaywallProduct]? = nil,
        introductoryOffersEligibilities: [String: AdaptyEligibility]? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.isPresented = isPresented
        self.fullScreen = fullScreen
        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
        self.products = products
        self.introductoryOffersEligibilities = introductoryOffersEligibilities
        self.tagResolver = tagResolver
        self.timerResolver = timerResolver
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didFailPurchase = didFailPurchase
        self.didCancelPurchase = didCancelPurchase
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRestore = didFailRestore
        self.didFailRendering = didFailRendering
        self.didFailLoadingProducts = didFailLoadingProducts
    }

    var paywallViewBody: some View {
        AdaptyPaywallView_Internal(
            logId: logId,
            paywall: paywall,
            products: products,
            introductoryOffersEligibilities: introductoryOffersEligibilities,
            configuration: viewConfiguration,
            tagResolver: tagResolver,
            timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
            showDebugOverlay: false,
            didPerformAction: didPerformAction ?? { action in
                switch action {
                case .close:
                    presentationMode.wrappedValue.dismiss()
                case let .openURL(url):
                    UIApplication.shared.open(url, options: [:])
                case .custom:
                    break
                }
            },
            didSelectProduct: didSelectProduct ?? { _ in },
            didStartPurchase: didStartPurchase ?? { _ in },
            didFinishPurchase: didFinishPurchase ?? { _, _ in
                presentationMode.wrappedValue.dismiss()
            },
            didFailPurchase: didFailPurchase,
            didCancelPurchase: didCancelPurchase ?? { _ in },
            didStartRestore: didStartRestore ?? {},
            didFinishRestore: didFinishRestore,
            didFailRestore: didFailRestore,
            didFailRendering: didFailRendering,
            didFailLoadingProducts: didFailLoadingProducts ?? { _ in true }
        )
    }

    public func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(isPresented: isPresented) {
                    paywallViewBody
                }

        } else {
            content
                .sheet(isPresented: isPresented) {
                    paywallViewBody
                }
        }
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    public func paywall(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywall: AdaptyPaywall,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        products: [AdaptyPaywallProduct]? = nil,
        introductoryOffersEligibilities: [String: AdaptyEligibility]? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil
    ) -> some View {
        modifier(
            AdaptyPaywallViewModifier(
                isPresented: isPresented,
                fullScreen: fullScreen,
                paywall: paywall,
                viewConfiguration: viewConfiguration,
                products: products,
                introductoryOffersEligibilities: introductoryOffersEligibilities,
                tagResolver: tagResolver,
                timerResolver: timerResolver,
                didPerformAction: didPerformAction ?? { action in
                    switch action {
                    case .close:
                        isPresented.wrappedValue = false
                    case let .openURL(url):
                        UIApplication.shared.open(url, options: [:])
                    case .custom:
                        break
                    }
                },
                didSelectProduct: didSelectProduct ?? { _ in },
                didStartPurchase: didStartPurchase ?? { _ in },
                didFinishPurchase: didFinishPurchase ?? { _, _ in
                    isPresented.wrappedValue = false
                },
                didFailPurchase: didFailPurchase,
                didCancelPurchase: didCancelPurchase ?? { _ in },
                didStartRestore: didStartRestore ?? {},
                didFinishRestore: didFinishRestore,
                didFailRestore: didFailRestore,
                didFailRendering: didFailRendering,
                didFailLoadingProducts: didFailLoadingProducts ?? { _ in true }
            )
        )
    }
}

#endif
