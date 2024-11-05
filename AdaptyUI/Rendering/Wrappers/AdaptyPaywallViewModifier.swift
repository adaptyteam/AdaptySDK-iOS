//
//  AdaptyPaywallView.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public struct AdaptyPaywallViewModifier<AlertItem>: ViewModifier where AlertItem: Identifiable {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let logId: String
    private let paywall: AdaptyPaywall
    private let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    private let products: [AdaptyPaywallProduct]?
    private let observerModeResolver: AdaptyObserverModeResolver?
    private let tagResolver: AdaptyTagResolver?
    private let timerResolver: AdaptyTimerResolver?

    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?
    private let didFailPurchase: (AdaptyPaywallProduct, AdaptyError) -> Void
    private let didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: (AdaptyProfile) -> Void
    private let didFailRestore: (AdaptyError) -> Void
    private let didFailRendering: (AdaptyError) -> Void
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?
    private let didPartiallyLoadProducts: (([String]) -> Void)?

    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?

    /// - Parameters:
    ///     - isPresented: A binding to a Boolean value that determines whether
    ///     to present the sheet.
    ///     - fullScreen: determines whether the screen will `.sheet` or `.fullScreenCover` function.
    ///     - paywall: an ``AdaptyPaywall`` object, for which you are going to show the screen.
    ///     - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///     - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///     - introductoryOffersEligibilities: optional ``[String: AdaptyEligibility]`` dictionary. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required eligibilities.
    ///     - observerModeResolver: if you are going to use AdaptyUI in Observer Mode, pass the resolver function here.
    ///     - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    ///     - timerResolver: if you are going to use custom timers functionality, pass the resolver function here.
    ///     - didPerformAction: If user performs an action, this callback will be invoked. There is a default implementation, e.g. `close` action will dismiss the paywall, `openUrl` action will open the URL.
    ///     - didSelectProduct: If product was selected for purchase (by user or by system), this callback will be invoked.
    ///     - didStartPurchase: If user initiates the purchase process, this callback will be invoked.
    ///     - didFinishPurchase: This method is invoked when a successful purchase is made.
    ///     - didFailPurchase: This method is invoked when the purchase process fails.
    ///     - didCancelPurchase: This method is invoked when user cancel the purchase manually.
    ///     - didStartRestore: If user initiates the restore process, this method will be invoked.
    ///     - didFinishRestore: This method is invoked when a successful restore is made.
    ///     Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    ///     - didFailRestore: This method is invoked when the restore process fails.
    ///     - didFailRendering: This method will be invoked in case of errors during the screen rendering process.
    ///     - didFailLoadingProducts: This method is invoked in case of errors during the products loading process. Return `true` if you want to retry the loading.
    public init(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywall: AdaptyPaywall,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        products: [AdaptyPaywallProduct]? = nil,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil,
        didPartiallyLoadProducts: (([String]) -> Void)? = nil,
        showAlertItem: Binding<AlertItem?>,
        showAlertBuilder: ((AlertItem) -> Alert)?
    ) {
        let logId = Log.stamp

        Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

        if AdaptyUI.isObserverModeEnabled && observerModeResolver == nil {
            Log.ui.warn("In order to handle purchases in Observer Mode enabled, provide the observerModeResolver!")
        } else if !AdaptyUI.isObserverModeEnabled && observerModeResolver != nil {
            Log.ui.warn("You should not pass observerModeResolver if you're using Adapty in Full Mode")
        }

        self.isPresented = isPresented
        self.fullScreen = fullScreen
        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
        self.products = products
        self.observerModeResolver = observerModeResolver
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
        self.didPartiallyLoadProducts = didPartiallyLoadProducts
        self.showAlertItem = showAlertItem
        self.showAlertBuilder = showAlertBuilder
    }

    var paywallViewBody: some View {
        AdaptyPaywallView_Internal(
            logId: logId,
            paywall: paywall,
            products: products,
            configuration: viewConfiguration,
            observerModeResolver: observerModeResolver,
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
            didFailLoadingProducts: didFailLoadingProducts ?? { _ in true },
            didPartiallyLoadProducts: didPartiallyLoadProducts ?? { _ in },
            showAlertItem: showAlertItem,
            showAlertBuilder: showAlertBuilder
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension View {
    /// Presents a paywall when a binding to a Boolean value that you
    /// provide is true.
    ///
    /// - Parameters:
    ///     - isPresented: A binding to a Boolean value that determines whether
    ///     to present the sheet.
    ///     - fullScreen: determines whether the screen will `.sheet` or `.fullScreenCover` function.
    ///     - paywall: an ``AdaptyPaywall`` object, for which you are going to show the screen.
    ///     - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///     - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///     - introductoryOffersEligibilities: optional ``[String: AdaptyEligibility]`` dictionary. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required eligibilities.
    ///     - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    ///     - timerResolver: if you are going to use custom timers functionality, pass the resolver function here.
    ///     - didPerformAction: If user performs an action, this callback will be invoked. There is a default implementation, e.g. `close` action will dismiss the paywall, `openUrl` action will open the URL.
    ///     - didSelectProduct: If product was selected for purchase (by user or by system), this callback will be invoked.
    ///     - didStartPurchase: If user initiates the purchase process, this callback will be invoked.
    ///     - didFinishPurchase: This method is invoked when a successful purchase is made.
    ///     - didFailPurchase: This method is invoked when the purchase process fails.
    ///     - didCancelPurchase: This method is invoked when user cancel the purchase manually.
    ///     - didStartRestore: If user initiates the restore process, this method will be invoked.
    ///     - didFinishRestore: This method is invoked when a successful restore is made.
    ///     Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    ///     - didFailRestore: This method is invoked when the restore process fails.
    ///     - didFailRendering: This method will be invoked in case of errors during the screen rendering process.
    ///     - didFailLoadingProducts: This method is invoked in case of errors during the products loading process. Return `true` if you want to retry the loading.
    ///     - showAlertItem:
    ///     - showAlertBuilder:
    @ViewBuilder
    func paywall<AlertItem: Identifiable>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywall: AdaptyPaywall,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        products: [AdaptyPaywallProduct]? = nil,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyProduct) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil,
        showAlertItem: Binding<AlertItem?> = Binding<AdaptyIdentifiablePlaceholder?>.constant(nil),
        showAlertBuilder: ((AlertItem) -> Alert)? = nil
    ) -> some View {
        modifier(
            AdaptyPaywallViewModifier<AlertItem>(
                isPresented: isPresented,
                fullScreen: fullScreen,
                paywall: paywall,
                viewConfiguration: viewConfiguration,
                products: products,
                observerModeResolver: observerModeResolver,
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
                didFailLoadingProducts: didFailLoadingProducts ?? { _ in true },
                showAlertItem: showAlertItem,
                showAlertBuilder: showAlertBuilder
            )
        )
    }
}

#endif
