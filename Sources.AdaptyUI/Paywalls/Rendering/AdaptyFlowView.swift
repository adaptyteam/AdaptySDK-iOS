//
//  AdaptyPaywallView.swift
//  Adapty
//
//  Created by Alexey Goncharov on 2/17/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import SwiftUI

@MainActor
public struct AdaptyFlowView<AlertItem>: View where AlertItem: Identifiable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let flowConfiguration: AdaptyUI.FlowConfiguration

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
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
        flowConfiguration: AdaptyUI.FlowConfiguration,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUI.Action) -> Void)? = nil,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)? = nil,
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
        self.flowConfiguration = flowConfiguration
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
        flowConfiguration.eventsHandler.didAppear = didAppear
        flowConfiguration.eventsHandler.didDisappear = didDisappear

        flowConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { action in
            switch action {
            case .close:
                presentationMode.wrappedValue.dismiss()
            case let .openURL(url):
                UIApplication.shared.open(url, options: [:])
            case .custom:
                break
            }
        }

        flowConfiguration.eventsHandler.didSelectProduct = didSelectProduct ?? { _ in }
        flowConfiguration.eventsHandler.didStartPurchase = didStartPurchase ?? { _ in }
        flowConfiguration.eventsHandler.didFinishPurchase = didFinishPurchase ?? { _, res in
            if !res.isPurchaseCancelled {
                presentationMode.wrappedValue.dismiss()
            }
        }
        flowConfiguration.eventsHandler.didFailPurchase = didFailPurchase
        flowConfiguration.eventsHandler.didStartRestore = didStartRestore ?? {}
        flowConfiguration.eventsHandler.didFinishRestore = didFinishRestore
        flowConfiguration.eventsHandler.didFailRestore = didFailRestore
        flowConfiguration.eventsHandler.didFailRendering = didFailRendering
        flowConfiguration.eventsHandler.didFailLoadingProducts = didFailLoadingProducts ?? { _ in true }
        flowConfiguration.eventsHandler.didPartiallyLoadProducts = didPartiallyLoadProducts

        flowConfiguration.eventsHandler.didFinishWebPaymentNavigation = didFinishWebPaymentNavigation ?? { _, _ in }

        return AdaptyUIPaywallView_Internal(
            showDebugOverlay: false,
            displayMissingTags: false
        )
        .environmentObjects(
            stateViewModel: flowConfiguration.stateViewModel,
            flowViewModel: flowConfiguration.flowViewModel,
            productsViewModel: flowConfiguration.productsViewModel,
            tagResolverViewModel: flowConfiguration.tagResolverViewModel,
            timerViewModel: flowConfiguration.timerViewModel,
            screensViewModel: flowConfiguration.screensViewModel,
            assetsViewModel: flowConfiguration.assetsViewModel
        )
        .onAppear {
            flowConfiguration.reportOnAppear()
        }
        .withAlert(item: showAlertItem, builder: showAlertBuilder)
    }
}

#endif
