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
    private var cancellables = Set<AnyCancellable>()

    package init(
        logId: String,
        actionHandler: AdaptyUIActionHandler,
        viewConfiguration: VC,
        isInspectable: Bool
    ) {
        self.logId = logId
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

    package init(
        productsViewModel: AdaptyUIProductsViewModel,
        screensViewModel: AdaptyUIScreensViewModel,
        logic: AdaptyUIBuilderLogic
    ) {
        self.productsViewModel = productsViewModel
        self.screensViewModel = screensViewModel
        self.logic = logic
    }

    package nonisolated func registerState(_ state: AdaptyUIState) {
        Task { @MainActor [weak self] in
            self?.state = state
        }
    }

    package nonisolated func openUrl(
        url: URL,
        openIn _: VC.Action.WebOpenInParameter
    ) {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.openURL(url: url))
        }
    }

    private func resolvedText(stringId: String) -> VC.RichText? {
        try? state?.richText(stringId)
    }

    package nonisolated func openUrl(
        stringId: String,
        openIn _: VC.Action.WebOpenInParameter
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

            self?.logic.reportDidPerformAction(.openURL(url: url))
        }
    }

    package nonisolated func userCustomAction(id: String) {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.custom(id: id))
        }
    }

    package nonisolated func purchaseProduct(
        productId: String,
        service: VC.Action.PaymentService
    ) {
        Task { @MainActor [weak self] in
            self?.productsViewModel.purchaseProduct(
                id: productId,
                service: service
            )
        }
    }

    package nonisolated func openWebPaywall(
        openIn _: VC.Action.WebOpenInParameter
    ) {
        // TODO: Deperecated
    }

    package nonisolated func restorePurchases() {
        Task { @MainActor [weak self] in
            self?.productsViewModel.restorePurchases()
        }
    }

    package nonisolated func closeAll() {
        Task { @MainActor [weak self] in
            self?.logic.reportDidPerformAction(.close)
        }
    }

    package nonisolated func selectProduct(
        productId: String
    ) {
        Task { @MainActor [weak self] in
            // TODO: move animation out of here
            withAnimation(.linear(duration: 0.0)) {
                self?.productsViewModel.selectProduct(
                    id: productId,
                    forGroupId: "paywallId deprecated" // TODO: x check
                )
            }
        }
    }

    package nonisolated func openScreen(
        instance: VS.ScreenInstance,
        transitionId: String
    ) {
        Task { @MainActor [weak self] in
            self?.screensViewModel.present(
                screen: instance,
                transitionId: transitionId,
                completion: {
                    // TODO: x report completion to Script
                }
            )
        }
    }

    package nonisolated func closeScreen(
        navigatorId: String,
        transitionId: String
    ) {
        Task { @MainActor [weak self] in
            self?.screensViewModel.dismiss(
                navigatorId: navigatorId,
                transitionId: transitionId,
                completion: {
                    // TODO: x report completion to Script
                }
            )
        }
    }

    package nonisolated func changeFocus(
        id: String?
    ) {
        Task { @MainActor [weak self] in
            self?.stateViewModel?.focusedId = id
        }
    }

    package nonisolated func setTimer(
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

    package nonisolated func setTimer(
        id: String,
        duration: TimeInterval,
        behavior: VC.SetTimerBehavior,
        callback: VS.JSAction?
    ) {
        if let callback { pendingTimerCallbacks[id] = callback }
        Task { @MainActor [weak self] in
            guard let self else { return }
            let cb = self.pendingTimerCallbacks.removeValue(forKey: id)
            self.timerViewModel?.setDuration(id: id, duration: duration, behavior: behavior, callback: cb)
        }
    }

    package nonisolated func moveScroll(
        instanceId: String,
        kind: VC.ScrollKind,
        value: VC.ScrollValue
    ) {
        Task { @MainActor [weak self] in
            self?.stateViewModel?.scrollCommand = .init(instanceId: instanceId, kind: kind, value: value)
        }
    }

    package nonisolated func showAlertDialog(
        params: VS.ShowAlertDialogParameters,
        callback: VS.JSAction?
    ) {
        pendingAlertDialogCallback = callback
        Task { @MainActor [weak self] in
            self?.stateViewModel?.showAlertDialog(params: params)
        }
    }

    package func handleAlertDialogResponse(actionId: String?, screenInstance: VS.ScreenInstance?) {
        let callback = pendingAlertDialogCallback
        pendingAlertDialogCallback = nil

        guard let callback, let screenInstance else { return }
        let response = VS.ShowAlertDialogParametersResponse(actionId: actionId)
        do {
            try state?.execute(action: callback, params: response, screenInstance: screenInstance)
        } catch {
            Log.ui.error("alertDialog callback error: \(error)")
        }
    }

    package func handleTimerCallback(timerId: String, callback: VS.JSAction) {
        guard let screenInstance = screensViewModel.topmostScreenInstance else { return }
        let response = VS.TimerResponse(timerId: timerId)
        do {
            try state?.execute(action: callback, params: response, screenInstance: screenInstance)
        } catch {
            Log.ui.error("timer callback error: \(error)")
        }
    }

    package nonisolated func showAppRate() {
        Task { @MainActor [weak self] in
            await self?.systemRequestsHandler?.handleAppReviewRequest()
        }
    }

    package nonisolated func showRequestPermission(params: VS.ShowRequestPermissionParameters, callback: VS.JSAction?) {
        pendingPermissionCallback = callback
        Task { @MainActor [weak self] in
            guard let self, let handler = self.systemRequestsHandler else { return }

            let permission = AdaptyUIPermission(jsString: params.permission ?? "custom")
            let result = await handler.handlePermission(permission, withCustomArgs: params.customArgs)

            let callback = self.pendingPermissionCallback
            self.pendingPermissionCallback = nil

            guard let callback, let screenInstance = self.screensViewModel.topmostScreenInstance else { return }

            let response = VS.ShowRequestPermissionParametersResponse(
                request: params,
                result: result.isGranted,
                detailResult: result.detail
            )

            do {
                try self.state?.execute(
                    action: callback,
                    params: response,
                    screenInstance: screenInstance
                )
            } catch {
                Log.ui.error("showRequestPermission callback error: \(error)")
            }
        }
    }
}

#endif

