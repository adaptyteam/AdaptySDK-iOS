//
//  Dev_AdaptyUIRendererView.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)
import AdaptyUI
import AdaptyUIBuilder
import SwiftUI

public extension AdaptyUI {
    @MainActor
    final class Dev_GalleryPreviewConfiguration {
        package let eventsHandler: AdaptyUIEventsHandler

        package let presentationViewModel: AdaptyUIPresentationViewModel
        package let stateViewModel: AdaptyUIStateViewModel
        package let actionHandler: AdaptyUIStateActionHandler
        package let paywallViewModel: AdaptyUIPaywallViewModel
        package let productsViewModel: AdaptyUIProductsViewModel
        package let tagResolverViewModel: AdaptyUITagResolverViewModel
        package let timerViewModel: AdaptyUITimerViewModel
        package let screensViewModel: AdaptyUIScreensViewModel
        package let assetsViewModel: AdaptyUIAssetsViewModel

        private let logic: AdaptyUIBuilderLogic

        fileprivate let logId: String
        fileprivate let observerModeResolver: AdaptyObserverModeResolver?
        fileprivate let tagResolver: AdaptyUITagResolver?
        fileprivate let timerResolver: AdaptyTimerResolver?
        fileprivate let assetsResolver: AdaptyUIAssetsResolver?

        package init(
            logId: String,
            viewConfiguration: AdaptyUIConfiguration,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?,
            systemRequestsHandler: AdaptyUISystemRequestsHandler?
        ) {
            self.logId = logId
            self.observerModeResolver = observerModeResolver
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver

            eventsHandler = AdaptyUIEventsHandler(logId: logId)
            logic = Dev_AdaptyUILogic(
                logId: logId,
                events: eventsHandler
            )
            presentationViewModel = AdaptyUIPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyUITagResolverViewModel(tagResolver: tagResolver)

            paywallViewModel = AdaptyUIPaywallViewModel(
                logId: logId,
                logic: logic,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyUIProductsViewModel(
                logId: logId,
                logic: logic,
                presentationViewModel: presentationViewModel,
                paywallViewModel: paywallViewModel,
                products: nil
            )
            screensViewModel = AdaptyUIScreensViewModel(
                logId: logId,
                viewConfiguration: viewConfiguration
            )
            actionHandler = AdaptyUIStateActionHandler(
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel,
                logic: logic
            )
            let stateHolder = AdaptyUIStateHolder(
                logId: logId,
                actionHandler: actionHandler,
                viewConfiguration: viewConfiguration,
                isInspectable: true
            )
            stateViewModel = AdaptyUIStateViewModel(
                logId: logId,
                logic: logic,
                stateHolder: stateHolder
            )
            actionHandler.stateViewModel = stateViewModel
            actionHandler.systemRequestsHandler = systemRequestsHandler
            let timerViewModel = AdaptyUITimerViewModel(
                logId: logId,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                stateViewModel: stateViewModel,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel
            )
            self.timerViewModel = timerViewModel
            actionHandler.timerViewModel = timerViewModel
            assetsViewModel = AdaptyUIAssetsViewModel(
                logId: logId,
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver(),
                stateHolder: stateHolder
            )

            stateHolder.start()
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

public struct Dev_AdaptyUIRendererView: View {
    let viewConfiguration: AdaptyUIConfiguration
    let galleryConfiguration: AdaptyUI.Dev_GalleryPreviewConfiguration

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    private let didSelectProduct: ((String) -> Void)?
    private let didStartPurchase: ((String) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFailRendering: ((AdaptyUIBuilderError) -> Void)?

    private let safeAreaOverride: EdgeInsets?

    public init(
        viewConfiguration: Dev_AdaptyUIConfiguration,
        assetsResolver: AdaptyUIAssetsResolver?,
        systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil,
        safeAreaOverride: EdgeInsets? = nil,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)? = nil,
        didSelectProduct: ((String) -> Void)? = nil,
        didStartPurchase: ((String) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFailRendering: ((AdaptyUIBuilderError) -> Void)? = nil
    ) {
        self.safeAreaOverride = safeAreaOverride
        self.viewConfiguration = viewConfiguration.wrapped
        galleryConfiguration = .init(
            logId: "test",
            viewConfiguration: viewConfiguration.wrapped,
            observerModeResolver: nil,
            tagResolver: ["TEST_TAG": "Adapty"],
            timerResolver: nil,
            assetsResolver: assetsResolver,
            systemRequestsHandler: systemRequestsHandler
        )

        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didStartRestore = didStartRestore
        self.didFailRendering = didFailRendering
    }

    public var body: some View {
        galleryConfiguration.eventsHandler.didAppear = didAppear
        galleryConfiguration.eventsHandler.didDisappear = didDisappear
        galleryConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { _ in }
        galleryConfiguration.eventsHandler.didSelectProduct = didSelectProduct.map { callback in
            { product in callback(product.adaptyProductId) }
        }
        galleryConfiguration.eventsHandler.didStartPurchase = didStartPurchase.map { callback in
            { product in callback(product.adaptyProductId) }
        }
        galleryConfiguration.eventsHandler.didStartRestore = didStartRestore
        galleryConfiguration.eventsHandler.didFailRendering = didFailRendering

        return AdaptyUIPaywallView_Internal(
            showDebugOverlay: false,
            displayMissingTags: true,
            safeAreaOverride: safeAreaOverride
        )
        .environmentObjects(
            stateViewModel: galleryConfiguration.stateViewModel,
            paywallViewModel: galleryConfiguration.paywallViewModel,
            productsViewModel: galleryConfiguration.productsViewModel,
            tagResolverViewModel: galleryConfiguration.tagResolverViewModel,
            timerViewModel: galleryConfiguration.timerViewModel,
            screensViewModel: galleryConfiguration.screensViewModel,
            assetsViewModel: galleryConfiguration.assetsViewModel
        )
    }
}

#endif
