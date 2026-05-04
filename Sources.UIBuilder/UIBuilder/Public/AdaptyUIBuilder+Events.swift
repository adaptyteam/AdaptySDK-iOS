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
    package var didStartRestore: (() -> Void)?
    package var didFailRendering: ((AdaptyUIBuilderError) -> Void)?
    package var didReceiveAnalyticEvent: ((String, [String: any Sendable]) -> Void)?

    package init(logId: String) {
        self.logId = logId
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didStartRestore = nil
        self.didFailRendering = nil
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

    // TODO: x check automatic behaviour
    package func event_didSelectProduct(_ product: ProductResolver, automatic: Bool) {
        Log.app.verbose("#\(logId)# event_didSelectProduct: \(product.flowId) automatic: \(automatic)")
        didSelectProduct?(product)
    }

    package func event_didStartPurchase(product: ProductResolver) {
        Log.app.verbose("#\(logId)# event_didStartPurchase")
        didStartPurchase?(product)
    }

    package func event_didStartRestore() {
        Log.app.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    package func event_didFailRendering(with error: AdaptyUIBuilderError) {
        Log.app.error("#\(logId)# event_didFailRendering: \(error)")
        didFailRendering?(error)
    }

    package func event_didReceiveAnalyticEvent(name: String, params: [String: any Sendable]) {
        Log.app.verbose("#\(logId)# event_didReceiveAnalyticEvent: \(name)")
        didReceiveAnalyticEvent?(name, params)
    }
}

#endif
