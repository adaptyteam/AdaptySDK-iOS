//
//  PromotedPurchaseIntentObserver.swift
//  AdaptySDK
//
//  Created by Codex on 30.06.2026.
//

import StoreKit

final class PromotedPurchaseIntentObserver: Sendable {
    #if os(iOS) || os(macOS)
    private let task: Task<Void, Never>?

    init() {
        guard #available(iOS 16.4, macOS 14.4, macCatalyst 16.4, *)
        else {
            task = nil
            return
        }

        task = Task {
            for await intent in PurchaseIntent.intents {
                await Self.handle(intent)
            }
        }
    }

    deinit {
        task?.cancel()
    }

    @available(iOS 16.4, macOS 14.4, macCatalyst 16.4, *)
    private static func handle(_ intent: PurchaseIntent) async {
        let subscriptionOffer: AdaptySubscriptionOffer? =
            if
                #available(iOS 18.0, macOS 15.0, macCatalyst 18.0, *),
                let offer = intent.offer
            {
                intent.product.adaptySubscriptionOffer(by: offer)
            } else {
                nil
            }

        let product = AdaptyPromotedProduct(
            skProduct: intent.product,
            subscriptionOffer: subscriptionOffer
        )

        let called = await Adapty.callDelegate {
            $0.didReceivePromotedPurchase(product)
        }

        if !called {
            Task {
                _ = try? await Adapty.makePurchase(product: product)
            }
        }
    }
    #endif
}
