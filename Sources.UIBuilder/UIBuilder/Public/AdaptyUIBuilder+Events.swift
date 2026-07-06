//
//  AdaptyUIEventsHandler.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUIEventsHandler {
    let logId: String

    package var didAppear: (() -> Void)?
    package var didDisappear: (() -> Void)?

    package var didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    package var didSelectProduct: ((ProductResolver) -> Void)?
    package var didStartPurchase: ((ProductResolver) -> Void)?
    package var didFinishPurchase: ((ProductResolver, VS.PurchaseResult) -> Void)?
    package var didStartRestore: (() -> Void)?
    package var didFinishRestore: ((VS.RestorePurchasesResult) -> Void)?
    package var didReceiveError: ((AdaptyUIBuilderError) -> Void)?
    package var didReceiveAnalyticEvent: ((String, [String: any Sendable]) -> Void)?

    package init(logId: String) {
        self.logId = logId
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didFinishPurchase = nil
        self.didStartRestore = nil
        self.didFinishRestore = nil
        self.didReceiveError = nil
        self.didReceiveAnalyticEvent = nil
    }

    package func event_viewDidAppear() {
        Log.app.verbose("#\(logId)# event_didAppear")
        didAppear?()
    }

    package func event_viewDidDisappear() {
        Log.app.verbose("#\(logId)# event_didDisappear")
        didDisappear?()
    }

    package func event_didPerformAction(_ action: AdaptyUIBuilder.Action) {
        Log.app.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    package func event_didSelectProduct(_ product: ProductResolver) {
        Log.app.verbose("#\(logId)# event_didSelectProduct: \(product.flowId)")
        didSelectProduct?(product)
    }

    package func event_didStartPurchase(product: ProductResolver) {
        Log.app.verbose("#\(logId)# event_didStartPurchase")
        didStartPurchase?(product)
    }

    package func event_didFinishPurchase(product: ProductResolver, result: VS.PurchaseResult) {
        Log.app.verbose("#\(logId)# event_didFinishPurchase: \(result.rawValue)")
        didFinishPurchase?(product, result)
    }

    package func event_didStartRestore() {
        Log.app.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    package func event_didFinishRestore(result: VS.RestorePurchasesResult) {
        Log.app.verbose("#\(logId)# event_didFinishRestore: \(result.rawValue)")
        didFinishRestore?(result)
    }

    package func event_didReceiveError(_ error: AdaptyUIBuilderError) {
        Log.app.error("#\(logId)# event_didReceiveError: \(error)")
        didReceiveError?(error)
    }

    package func event_didReceiveAnalyticEvent(name: String, params: [String: any Sendable]) {
        Log.app.verbose("#\(logId)# event_didReceiveAnalyticEvent: \(name)")
        didReceiveAnalyticEvent?(name, params)
    }
}

#endif
