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
struct AdaptyPaywallViewModifier<AlertItem>: ViewModifier where AlertItem: Identifiable {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let paywallConfiguration: AdaptyUI.PaywallConfiguration
    private let showAlertItem: Binding<AlertItem?>
    private let showAlertBuilder: ((AlertItem) -> Alert)?

    init(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUI.PaywallConfiguration,
        showAlertItem: Binding<AlertItem?>,
        showAlertBuilder: ((AlertItem) -> Alert)?
    ) {
        self.isPresented = isPresented
        self.fullScreen = fullScreen
        self.paywallConfiguration = paywallConfiguration
        self.showAlertItem = showAlertItem
        self.showAlertBuilder = showAlertBuilder
    }

    var paywallViewBody: some View {
        AdaptyPaywallView_Internal(
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
        .environmentObject(paywallConfiguration.videoViewModel)
        .environmentObject(paywallConfiguration.assetViewModel)
        .onAppear {
            paywallConfiguration.eventsHandler.viewDidAppear()
            paywallConfiguration.paywallViewModel.logShowPaywall()
        }
    }

    public func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration.eventsHandler.viewDidDisappear()
                        paywallConfiguration.paywallViewModel.resetLogShowPaywall()
                    },
                    content: {
                        paywallViewBody
                    }
                )
        } else {
            content
                .sheet(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration.eventsHandler.viewDidDisappear()
                        paywallConfiguration.paywallViewModel.resetLogShowPaywall()
                    },
                    content: {
                        paywallViewBody
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
    ///     - didPerformAction: If user performs an action, this callback will be invoked. There is a default implementation, e.g. `close` action will dismiss the paywall, `openUrl` action will open the URL.
    ///     - didSelectProduct: If product was selected for purchase (by user or by system), this callback will be invoked.
    ///     - didStartPurchase: If user initiates the purchase process, this callback will be invoked.
    ///     - didFinishPurchase: This method is invoked when a successful purchase is made.
    ///     - didFailPurchase: This method is invoked when the purchase process fails.
    ///     - didStartRestore: If user initiates the restore process, this method will be invoked.
    ///     - didFinishRestore: This method is invoked when a successful restore is made.
    ///     Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    ///     - didFailRestore: This method is invoked when the restore process fails.
    ///     - didFailRendering: This method will be invoked in case of errors during the screen rendering process.
    ///     - didFailLoadingProducts: This method is invoked in case of errors during the products loading process. Return `true` if you want to retry the loading.
    ///     - showAlertItem:
    ///     - showAlertBuilder:
    func paywall<AlertItem: Identifiable>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUI.PaywallConfiguration,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyProduct) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)? = nil,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: ((AdaptyError) -> Bool)? = nil,
        showAlertItem: Binding<AlertItem?> = Binding<AdaptyIdentifiablePlaceholder?>.constant(nil),
        showAlertBuilder: ((AlertItem) -> Alert)? = nil
    ) -> some View {
        paywallConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { action in
            switch action {
            case .close:
                isPresented.wrappedValue = false
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
                isPresented.wrappedValue = false
            }
        }
        paywallConfiguration.eventsHandler.didFailPurchase = didFailPurchase
        paywallConfiguration.eventsHandler.didStartRestore = didStartRestore ?? {}
        paywallConfiguration.eventsHandler.didFinishRestore = didFinishRestore
        paywallConfiguration.eventsHandler.didFailRestore = didFailRestore
        paywallConfiguration.eventsHandler.didFailRendering = didFailRendering
        paywallConfiguration.eventsHandler.didFailLoadingProducts = didFailLoadingProducts ?? { _ in true }

        return modifier(
            AdaptyPaywallViewModifier<AlertItem>(
                isPresented: isPresented,
                fullScreen: fullScreen,
                paywallConfiguration: paywallConfiguration,
                showAlertItem: showAlertItem,
                showAlertBuilder: showAlertBuilder
            )
        )
    }
}

#endif
