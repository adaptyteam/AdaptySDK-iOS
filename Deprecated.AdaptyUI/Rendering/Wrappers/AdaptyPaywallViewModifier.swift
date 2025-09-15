//
//  AdaptyPaywallViewModifier.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public struct AdaptyLoadingPlaceholderView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyPaywallViewModifier<Placeholder, AlertItem>: ViewModifier where AlertItem: Identifiable, Placeholder: View {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let paywallConfiguration: AdaptyUI.PaywallConfiguration?

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?
    private let didFailPurchase: (AdaptyPaywallProduct, AdaptyError) -> Void
    private let didFinishWebPaymentNavigation: ((AdaptyPaywallProduct?, AdaptyError?) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: (AdaptyProfile) -> Void
    private let didFailRestore: (AdaptyError) -> Void
    private let didFailRendering: (AdaptyUIError) -> Void
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?
    private let didPartiallyLoadProducts: (([String]) -> Void)?
    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?
    private let placeholderBuilder: (() -> Placeholder)?

    init(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUI.PaywallConfiguration?,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)?,
        didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)?,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didFinishWebPaymentNavigation: ((AdaptyPaywallProduct?, AdaptyError?) -> Void)? = nil,
        didStartRestore: (() -> Void)?,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyUIError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)?,
        didPartiallyLoadProducts: (([String]) -> Void)?,
        showAlertItem: Binding<AlertItem?>,
        showAlertBuilder: ((AlertItem) -> Alert)?,
        placeholderBuilder: (() -> Placeholder)?
    ) {
        self.isPresented = isPresented
        self.fullScreen = fullScreen
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
        self.placeholderBuilder = placeholderBuilder
    }

    @ViewBuilder
    private var paywallOrProgressView: some View {
        if let paywallConfiguration {
            AdaptyPaywallView(
                paywallConfiguration: paywallConfiguration,
                didAppear: didAppear,
                didDisappear: didDisappear,
                didPerformAction: didPerformAction,
                didSelectProduct: didSelectProduct,
                didStartPurchase: didStartPurchase,
                didFinishPurchase: didFinishPurchase,
                didFailPurchase: didFailPurchase,
                didFinishWebPaymentNavigation: didFinishWebPaymentNavigation,
                didStartRestore: didStartRestore,
                didFinishRestore: didFinishRestore,
                didFailRestore: didFailRestore,
                didFailRendering: didFailRendering,
                didFailLoadingProducts: didFailLoadingProducts,
                didPartiallyLoadProducts: didPartiallyLoadProducts,
                showAlertItem: showAlertItem,
                showAlertBuilder: showAlertBuilder
            )
        } else if let placeholderBuilder {
            placeholderBuilder()
        } else {
            AdaptyLoadingPlaceholderView()
        }
    }

    public func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration?.reportOnDisappear()
                    },
                    content: {
                        paywallOrProgressView
                    }
                )
        } else {
            content
                .sheet(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration?.reportOnDisappear()
                    },
                    content: {
                        paywallOrProgressView
                    }
                )
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
    ///     - paywallConfiguration: an ``AdaptyUI.PaywallConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.paywallConfiguration(for:products:viewConfiguration:observerModeResolver:tagResolver:timerResolver:)`` method.
    ///     - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    ///     - timerResolver: if you are going to use custom timers functionality, pass the resolver function here.
    ///     - didAppear: This callback is invoked when the paywall view was presented.
    ///     - didDisappear: This callback is invoked when the paywall view was dismissed.
    ///     - didPerformAction: If user performs an action, this callback will be invoked. There is a default implementation, e.g. `close` action will dismiss the paywall, `openUrl` action will open the URL.
    ///     - didSelectProduct: If product was selected for purchase (by user or by system), this callback will be invoked.
    ///     - didStartPurchase: If user initiates the purchase process, this callback will be invoked.
    ///     - didFinishPurchase: This callback is invoked when a successful purchase is made.
    ///     - didFailPurchase: This callback is invoked when the purchase process fails.
    ///     - didStartRestore: If user initiates the restore process, this callback will be invoked.
    ///     - didFinishRestore: This callback is invoked when a successful restore is made.
    ///     Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    ///     - didFailRestore: This callback is invoked when the restore process fails.
    ///     - didFailRendering: This callback will be invoked in case of errors during the screen rendering process.
    ///     - didFailLoadingProducts: This callback is invoked in case of errors during the products loading process. Return `true` if you want to retry the loading.
    ///     - showAlertItem:
    ///     - showAlertBuilder:
    func paywall<Placeholder: View, AlertItem: Identifiable>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUI.PaywallConfiguration?,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyProduct) -> Void)? = nil,
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
        showAlertBuilder: ((AlertItem) -> Alert)? = nil,
        placeholderBuilder: (() -> Placeholder)? = { AdaptyLoadingPlaceholderView() }
    ) -> some View {
        modifier(
            AdaptyPaywallViewModifier<Placeholder, AlertItem>(
                isPresented: isPresented,
                fullScreen: fullScreen,
                paywallConfiguration: paywallConfiguration,
                didAppear: didAppear,
                didDisappear: didDisappear,
                didPerformAction: didPerformAction,
                didSelectProduct: didSelectProduct,
                didStartPurchase: didStartPurchase,
                didFinishPurchase: didFinishPurchase,
                didFailPurchase: didFailPurchase,
                didFinishWebPaymentNavigation: didFinishWebPaymentNavigation,
                didStartRestore: didStartRestore,
                didFinishRestore: didFinishRestore,
                didFailRestore: didFailRestore,
                didFailRendering: didFailRendering,
                didFailLoadingProducts: didFailLoadingProducts,
                didPartiallyLoadProducts: didPartiallyLoadProducts,
                showAlertItem: showAlertItem,
                showAlertBuilder: showAlertBuilder,
                placeholderBuilder: placeholderBuilder
            )
        )
    }
}

#endif
