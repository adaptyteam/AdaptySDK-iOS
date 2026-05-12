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
        package let flowViewModel: AdaptyUIFlowViewModel
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
            previewProducts: [Dev_PreviewProduct],
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?,
            systemRequestsHandler: AdaptyUISystemRequestsHandler?,
            rtlOverride: Bool?
        ) {
            self.logId = logId
            self.observerModeResolver = observerModeResolver
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver

            eventsHandler = AdaptyUIEventsHandler(logId: logId)
            logic = Dev_AdaptyUILogic(
                logId: logId,
                events: eventsHandler,
                products: previewProducts.map(Dev_MockProduct.init(from:))
            )
            presentationViewModel = AdaptyUIPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyUITagResolverViewModel(tagResolver: tagResolver)

            flowViewModel = AdaptyUIFlowViewModel(
                logId: logId,
                logic: logic,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyUIProductsViewModel(
                logId: logId,
                logic: logic,
                presentationViewModel: presentationViewModel,
                flowViewModel: flowViewModel,
                products: nil
            )
            screensViewModel = AdaptyUIScreensViewModel(
                logId: logId,
                viewConfiguration: viewConfiguration,
                rtlOverride: rtlOverride
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
                flowViewModel: flowViewModel,
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel
            )
            self.timerViewModel = timerViewModel
            actionHandler.timerViewModel = timerViewModel
            timerViewModel.callbackHandler = actionHandler
            assetsViewModel = AdaptyUIAssetsViewModel(
                logId: logId,
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver(),
                stateHolder: stateHolder
            )

            productsViewModel.onProductsLoaded = { [weak stateHolder, previewProducts] _ in
                stateHolder?.setProducts(previewProducts.asProductConstants())
            }

            stateHolder.start()
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

public struct Dev_AdaptyUIRendererView: View {
    let viewConfiguration: AdaptyUIConfiguration
    let galleryConfiguration: AdaptyUI.Dev_GalleryPreviewConfiguration

    private let didAppear: () -> Void
    private let didDisappear: () -> Void
    private let didPerformAction: (AdaptyUIBuilder.Action) -> Void
    private let didSelectProduct: (String) -> Void
    private let didStartPurchase: (String) -> Void
    private let didFinishPurchase: (String, String) -> Void
    private let didStartRestore: () -> Void
    private let didFinishRestore: (String) -> Void
    private let didFailRendering: (AdaptyUIBuilderError) -> Void
    private let didReceiveAnalyticEvent: (String, [String: any Sendable]) -> Void

    private let safeAreaOverride: EdgeInsets?
    private let showDebugOverlay: Bool
    private let displayMissingTags: Bool

    public init(
        viewConfiguration: Dev_AdaptyUIConfiguration,
        assetsResolver: AdaptyUIAssetsResolver?,
        systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil,
        showDebugOverlay: Bool = false,
        displayMissingTags: Bool = true,
        safeAreaOverride: EdgeInsets? = nil,
        rtlOverride: Bool? = nil,
        didAppear: @escaping () -> Void,
        didDisappear: @escaping () -> Void,
        didPerformAction: @escaping (AdaptyUIBuilder.Action) -> Void,
        didSelectProduct: @escaping (String) -> Void,
        didStartPurchase: @escaping (String) -> Void,
        didFinishPurchase: @escaping (String, String) -> Void,
        didStartRestore: @escaping () -> Void,
        didFinishRestore: @escaping (String) -> Void,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void,
        didReceiveAnalyticEvent: @escaping (String, [String: any Sendable]) -> Void
    ) {
        self.safeAreaOverride = safeAreaOverride
        self.showDebugOverlay = showDebugOverlay
        self.displayMissingTags = displayMissingTags
        self.viewConfiguration = viewConfiguration.wrapped
        galleryConfiguration = .init(
            logId: "test",
            viewConfiguration: viewConfiguration.wrapped,
            previewProducts: viewConfiguration.previewProducts,
            observerModeResolver: nil,
            tagResolver: ["TEST_TAG": "Adapty"],
            timerResolver: nil,
            assetsResolver: assetsResolver,
            systemRequestsHandler: systemRequestsHandler,
            rtlOverride: rtlOverride
        )

        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRendering = didFailRendering
        self.didReceiveAnalyticEvent = didReceiveAnalyticEvent
    }

    public var body: some View {
        galleryConfiguration.eventsHandler.didAppear = didAppear
        galleryConfiguration.eventsHandler.didDisappear = didDisappear
        galleryConfiguration.eventsHandler.didPerformAction = didPerformAction
        galleryConfiguration.eventsHandler.didSelectProduct = { [didSelectProduct] product in
            didSelectProduct(product.flowId)
        }
        galleryConfiguration.eventsHandler.didStartPurchase = { [didStartPurchase] product in
            didStartPurchase(product.flowId)
        }
        galleryConfiguration.eventsHandler.didFinishPurchase = { [didFinishPurchase] product, result in
            didFinishPurchase(product.flowId, result.rawValue)
        }
        galleryConfiguration.eventsHandler.didStartRestore = didStartRestore
        galleryConfiguration.eventsHandler.didFinishRestore = { [didFinishRestore] result in
            didFinishRestore(result.rawValue)
        }
        galleryConfiguration.eventsHandler.didFailRendering = didFailRendering
        galleryConfiguration.eventsHandler.didReceiveAnalyticEvent = didReceiveAnalyticEvent

        return AdaptyUIPaywallView_Internal(
            showDebugOverlay: showDebugOverlay,
            displayMissingTags: displayMissingTags,
            safeAreaOverride: safeAreaOverride
        )
        .environmentObjects(
            stateViewModel: galleryConfiguration.stateViewModel,
            flowViewModel: galleryConfiguration.flowViewModel,
            productsViewModel: galleryConfiguration.productsViewModel,
            tagResolverViewModel: galleryConfiguration.tagResolverViewModel,
            timerViewModel: galleryConfiguration.timerViewModel,
            screensViewModel: galleryConfiguration.screensViewModel,
            assetsViewModel: galleryConfiguration.assetsViewModel
        )
    }
}

#endif
