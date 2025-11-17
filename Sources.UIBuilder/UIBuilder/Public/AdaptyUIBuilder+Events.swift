//
//  AdaptyUIEventsHandler.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUIEventsHandler: ObservableObject {
    let logId: String

    var didAppear: (() -> Void)?
    var didDisappear: (() -> Void)?

    var didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    var didSelectProduct: ((ProductResolver) -> Void)?
    var didStartPurchase: ((ProductResolver) -> Void)?
    var didStartRestore: (() -> Void)?
    var didFailRendering: ((AdaptyUIBuilderError) -> Void)?

    package init(logId: String) {
        self.logId = logId
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didStartRestore = nil
        self.didFailRendering = nil
    }

    func event_viewDidAppear() {
        Log.app.verbose("#\(logId)# event_didAppear")
        didAppear?()
    }

    func event_viewDidDisappear() {
        Log.app.verbose("#\(logId)# event_didDisappear")
        didDisappear?()
    }

    func event_didPerformAction(_ action: AdaptyUIBuilder.Action) {
        Log.app.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ product: ProductResolver, automatic: Bool) {
        Log.app.verbose("#\(logId)# event_didSelectProduct: \(product.adaptyProductId) automatic: \(automatic)")
        didSelectProduct?(product)
    }

    func event_didStartPurchase(product: ProductResolver) {
        Log.app.verbose("#\(logId)# event_didStartPurchase")
        didStartPurchase?(product)
    }

    func event_didStartRestore() {
        Log.app.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    func event_didFailRendering(with error: AdaptyUIBuilderError) {
        Log.app.error("#\(logId)# event_didFailRendering: \(error)")
        didFailRendering?(error)
    }
}

#endif
