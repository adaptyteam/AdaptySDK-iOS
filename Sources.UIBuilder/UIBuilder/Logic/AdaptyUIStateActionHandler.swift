//
//  AdaptyUIStateActionHandler.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/18/25.
//

#if canImport(UIKit)

import Combine
import Foundation
import SwiftUI

@MainActor
package final class AdaptyUIStateHolder {
    let state: AdaptyUIState

    private let logId: String
    private let actionHandler: AdaptyUIStateActionHandler
    private var cancellables = Set<AnyCancellable>()
    private var lastProducts: [VC.FlowConstants.ProductConstants]?

    package init(
        logId: String,
        actionHandler: AdaptyUIStateActionHandler,
        viewConfiguration: VC,
        isInspectable: Bool
    ) {
        self.logId = logId
        self.actionHandler = actionHandler
        self.state = AdaptyUIState(
            name: "AdaptyJSState_[\(logId)]",
            configuration: viewConfiguration,
            actionHandler: actionHandler,
            isInspectable: isInspectable
        )

        actionHandler.registerState(state)
    }

    package func start() {
//        state.objectWillChange
//            .sink { [weak self] _ in
        // TODO: x propagate state
//                if let state = self?.state {
//                    print("#STATE_DEBUG# \(state.debug(filter: .withFunctionCode))")
//                }
//            }
//            .store(in: &cancellables)

        state.startOnce()
    }

    package func setProducts(_ products: [VC.FlowConstants.ProductConstants]) {
        lastProducts = products
        state.setProductsConstants(products)
    }

    package func prepareForReuse() {
        Log.ui.verbose("#\(logId)# prepareForReuse")
        actionHandler.clearPendingCallbacks()
        state.prepareForReuse()
        if let lastProducts {
            state.setProductsConstants(lastProducts)
        }
    }
}

@MainActor
package final class AdaptyUIStateActionHandler: AdaptyUIActionHandler, AdaptyUITimerCallbackHandler {
    private let productsViewModel: AdaptyUIProductsViewModel
    private let screensViewModel: AdaptyUIScreensViewModel

    private let logic: AdaptyUIBuilderLogic
    private weak var state: AdaptyUIState?

    package weak var stateViewModel: AdaptyUIStateViewModel? {
        didSet {
            stateViewModel?.onAlertDialogResponse = { [weak self] actionId, screenInstance in
                self?.handleAlertDialogResponse(actionId: actionId, screenInstance: screenInstance)
            }
        }
    }

    package weak var timerViewModel: AdaptyUITimerViewModel?

    package var systemRequestsHandler: AdaptyUISystemRequestsHandler?

    private nonisolated(unsafe) var pendingAlertDialogCallback: VS.JSAction?
    private nonisolated(unsafe) var pendingPermissionCallback: VS.JSAction?
    private nonisolated(unsafe) var pendingTimerCallbacks: [String: VS.JSAction] = [:]
    private nonisolated(unsafe) var pendingPurchaseCallbacks: [String: VS.JSAction] = [:]
    private nonisolated(unsafe) var pendingRestoreCallbacks: [String: VS.JSAction] = [:]

    package init(
        productsViewModel: AdaptyUIProductsViewModel,
        screensViewModel: AdaptyUIScreensViewModel,
        logic: AdaptyUIBuilderLogic
    ) {
        self.productsViewModel = productsViewModel
        self.screensViewModel = screensViewModel
        self.logic = logic
    }

    nonisolated func registerState(_ state: AdaptyUIState) {
        Task { @MainActor [weak self] in
            self?.state = state
            self?.screensViewModel.executeActions = { [weak state] actions, screen in
                try? state?.execute(actions: actions, screenInstance: screen)
            }
        }
    }

    nonisolated func jsException(_ message: String) {
        Task { @MainActor [weak self] in
            self?.logic.reportDidReceiveError(.jsException(message))
        }
    }

    nonisolated func openUrl(
        url: URL,
        openIn: VC.Action.WebOpenInParameter
    ) {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.openURL(url: url, in: openIn.toWebPresentation))
        }
    }

    private func resolvedText(stringId: String) -> VC.RichText? {
        try? state?.richText(stringId)
    }

    nonisolated func openUrl(
        stringId: String,
        openIn: VC.Action.WebOpenInParameter
    ) {
        Task { @MainActor [weak self] in
            guard
                let text = self?.resolvedText(stringId: stringId),
                let str = text.asString,
                let url = URL(string: str)
            else {
                // TODO: x warn
                return
            }

            self?.logic.reportDidPerformAction(.openURL(url: url, in: openIn.toWebPresentation))
        }
    }

    nonisolated func userCustomAction(id: String) {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.custom(id: id))
        }
    }

    nonisolated func purchaseProduct(
        productId: String,
        service: VC.Action.PaymentService,
        callback: VS.JSAction?
    ) {
        let token = UUID().uuidString

        if let callback {
            pendingPurchaseCallbacks[token] = callback
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.state?.sendSDKEvent(.willPurchase(productId: productId))

            self.productsViewModel.purchaseProduct(
                id: productId,
                service: service,
                onFinish: { [weak self] result in
                    guard let self else { return }

                    self.state?.sendSDKEvent(.didPurchase(productId: productId, result: result))

                    guard let callback = self.pendingPurchaseCallbacks.removeValue(forKey: token) else { return }

                    do {
                        try self.state?.execute(
                            action: callback,
                            response: VS.PurchaseResponse(productId: productId, result: result)
                        )
                    } catch {
                        Log.ui.error("purchase callback error: \(error)")
                    }
                }
            )
        }
    }

    nonisolated func openWebPaywall(
        openIn _: VC.Action.WebOpenInParameter
    ) {
        // TODO: Deperecated
    }

    nonisolated func restorePurchases(callback: VS.JSAction?) {
        let token = UUID().uuidString

        if let callback { pendingRestoreCallbacks[token] = callback }

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.state?.sendSDKEvent(.willRestorePurchases)

            self.productsViewModel.restorePurchases(
                onFinish: { [weak self] result in
                    guard let self else { return }

                    self.state?.sendSDKEvent(.didRestorePurchases(result: result))

                    guard let callback = self.pendingRestoreCallbacks.removeValue(forKey: token) else { return }

                    do {
                        try self.state?.execute(
                            action: callback,
                            response: VS.RestorePurchasesResponse(result: result)
                        )
                    } catch {
                        Log.ui.error("restore callback error: \(error)")
                    }
                }
            )
        }
    }

    nonisolated func closeAll() {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.close)
        }
    }

    nonisolated func selectProduct(
        productId: String
    ) {
        Task { @MainActor [weak self] in
            self?.productsViewModel.selectProduct(id: productId)
        }
    }

    nonisolated func openScreen(
        instance: VS.ScreenInstance,
        transitionId: String
    ) {
        Task { @MainActor [weak self] in
            self?.screensViewModel.present(
                screen: instance,
                transitionId: transitionId,
                completion: nil
            )
        }
    }

    nonisolated func closeScreen(
        navigatorId: String,
        transitionId: String
    ) {
        Task { @MainActor [weak self] in
            self?.screensViewModel.dismiss(
                navigatorId: navigatorId,
                transitionId: transitionId,
                completion: nil
            )
        }
    }

    nonisolated func changeFocus(
        id: String?
    ) {
        Task { @MainActor [weak self] in
            self?.stateViewModel?.focusedId = id
        }
    }

    nonisolated func setTimer(
        id: String,
        endAt: Date,
        callback: VS.JSAction?
    ) {
        if let callback { pendingTimerCallbacks[id] = callback }
        Task { @MainActor [weak self] in
            guard let self else { return }
            let cb = self.pendingTimerCallbacks.removeValue(forKey: id)
            self.timerViewModel?.setEndDate(id: id, date: endAt, callback: cb)
        }
    }

    nonisolated func setTimer(
        id: String,
        duration: TimeInterval,
        behavior: VS.SetTimerBehavior,
        callback: VS.JSAction?
    ) {
        if let callback { pendingTimerCallbacks[id] = callback }
        Task { @MainActor [weak self] in
            guard let self else { return }
            let cb = self.pendingTimerCallbacks.removeValue(forKey: id)
            self.timerViewModel?.setDuration(id: id, duration: duration, behavior: behavior, callback: cb)
        }
    }

    nonisolated func moveScroll(
        instanceId: String,
        kind: VS.ScrollKind,
        value: VS.ScrollValue
    ) {
        Task { @MainActor [weak self] in
            self?.stateViewModel?.scrollCommand = .init(instanceId: instanceId, kind: kind, value: value)
        }
    }

    nonisolated func showAlertDialog(
        params: VS.ShowAlertDialogParameters,
        callback: VS.JSAction?
    ) {
        pendingAlertDialogCallback = callback
        Task { @MainActor [weak self] in
            self?.stateViewModel?.showAlertDialog(params: params)
        }
    }

    package func clearPendingCallbacks() {
        pendingAlertDialogCallback = nil
        pendingPermissionCallback = nil
        pendingTimerCallbacks.removeAll()
        pendingPurchaseCallbacks.removeAll()
        pendingRestoreCallbacks.removeAll()
    }

    func handleAlertDialogResponse(actionId: String?, screenInstance: VS.ScreenInstance?) {
        let callback = pendingAlertDialogCallback
        pendingAlertDialogCallback = nil

        guard let callback, screenInstance != nil else { return }
        let response = VS.ShowAlertDialogParametersResponse(actionId: actionId)
        do {
            try state?.execute(action: callback, response: response)
        } catch {
            Log.ui.error("alertDialog callback error: \(error)")
        }
    }

    func handleTimerCallback(timerId: String, callback: VS.JSAction) {
        guard screensViewModel.topmostScreenInstance != nil else { return }
        let response = VS.TimerResponse(timerId: timerId)
        do {
            try state?.execute(action: callback, response: response)
        } catch {
            Log.ui.error("timer callback error: \(error)")
        }
    }

    nonisolated func showAppRate() {
        Task { @MainActor [weak self] in
            await self?.systemRequestsHandler?.handleAppReviewRequest()
        }
    }

    nonisolated func showRequestPermission(params: VS.ShowRequestPermissionParameters, callback: VS.JSAction?) {
        pendingPermissionCallback = callback
        Task { @MainActor [weak self] in
            guard let self, let handler = self.systemRequestsHandler else { return }

            let permission = AdaptyUIPermission(jsString: params.permission ?? "custom")
            let result = await handler.handlePermission(permission, withCustomArgs: params.customArgs)

            let callback = self.pendingPermissionCallback
            self.pendingPermissionCallback = nil

            guard let callback, self.screensViewModel.topmostScreenInstance != nil else { return }

            let response = VS.ShowRequestPermissionParametersResponse(
                request: params,
                result: result.isGranted,
                detailResult: result.detail
            )

            do {
                try self.state?.execute(
                    action: callback,
                    response: response
                )
            } catch {
                Log.ui.error("showRequestPermission callback error: \(error)")
            }
        }
    }

    nonisolated func sendEvents(instanceId: String?, eventIds: [String]) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            for eventIdStr in eventIds {
                let eventId = VC.EventHandler.EventId.custom(eventIdStr)

                if let instanceId {
                    for navigatorVM in self.screensViewModel.navigatorsViewModels {
                        if navigatorVM.currentScreenInstanceIfSingle?.id == instanceId {
                            navigatorVM.eventBus.publish(
                                eventId: eventId,
                                transitionId: nil,
                                screenInstanceId: instanceId
                            )
                        }
                    }
                } else {
                    for navigatorVM in self.screensViewModel.navigatorsViewModels {
                        navigatorVM.eventBus.publish(
                            eventId: eventId,
                            transitionId: nil,
                            screenInstanceId: nil
                        )
                    }
                }
            }
        }
    }

    nonisolated func sendAnalyticsEvent(_ event: VS.AnalyticEvent) {
        Task { @MainActor [weak self] in
            if event.isBackend {
                self?.logic.reportBackendAnalyticEvent(event)
            }

            if event.isCustomer {
                self?.logic.reportCustomerAnalyticEvent(
                    name: event.name,
                    params: event.params
                )
            }
        }
    }
}

#endif
