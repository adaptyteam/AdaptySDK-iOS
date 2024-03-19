//
//  SKProductsManager+PurchasedSK2Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2023
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SKProductsManager {
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String? = nil,
        purchasedSK2Transaction transaction: SK2Transaction,
        _ completion: @escaping (PurchasedTransaction) -> Void
    ) {
        let productId = transaction.productID

        fetchSK2Product(productIdentifier: productId, fetchPolicy: .returnCacheDataElseLoad) { result in
            if let error = result.error {
                Log.error("SK1QueueManager: fetch SK2Product \(productId) error: \(error)")
            }
            completion(PurchasedTransaction(
                sk2Product: try? result.get(),
                variationId: variationId,
                persistentVariationId: persistentVariationId,
                purchasedSK2Transaction: transaction
            ))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction {
    init(
        sk2Product: SK2Product?,
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK2Transaction transaction: SK2Transaction
    ) {
        let offer: PurchasedTransaction.SubscriptionOffer? = {
            #if swift(>=5.9.2) && (!os(visionOS) || swift(>=5.10))
                if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                    return .init(transaction.offer, sk2Product: sk2Product)
                }
            #endif
            return .init(transaction, sk2Product: sk2Product)
        }()

        self.init(
            transactionId: transaction.ext.identifier,
            originalTransactionId: transaction.ext.originalIdentifier,
            vendorProductId: transaction.productID,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.ext.currencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.ext.regionCode,
            subscriptionOffer: offer,
            environment: transaction.ext.environment
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction.SubscriptionOffer {
    init?(_ transaction: SK2Transaction, sk2Product: SK2Product?) {
        guard let offerType = transaction.ext.offerType else { return nil }
        let productOffer = sk2Product?.subscriptionOffer(byType: offerType, withId: transaction.ext.offerId)
        self = .init(
            id: transaction.ext.offerId,
            period: (productOffer?.period).map { AdaptyProductSubscriptionPeriod(subscriptionPeriod: $0) },
            paymentMode: (productOffer?.paymentMode).map { .init(mode: $0) } ?? .unknown,
            type: .init(type: offerType),
            price: productOffer?.price
        )
    }

    #if swift(>=5.9.2) && (!os(visionOS) || swift(>=5.10))
        @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
        init?(_ transactionOffer: SK2Transaction.Offer?, sk2Product: SK2Product?) {
            guard let transactionOffer else { return nil }
            let productOffer = sk2Product?.subscriptionOffer(byType: transactionOffer.type, withId: transactionOffer.id)
            self = .init(
                id: transactionOffer.id,
                period: (productOffer?.period).map { .init(subscriptionPeriod: $0) },
                paymentMode: transactionOffer.paymentMode.map { .init(mode: $0) } ?? .unknown,
                type: .init(type: transactionOffer.type),
                price: productOffer?.price
            )
        }
    #endif
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension SK2Product {
    func subscriptionOffer(
        byType offerType: SK2Transaction.OfferType,
        withId offerId: String?
    ) -> SK2Product.SubscriptionOffer? {
        guard let subscription else { return nil }

        switch offerType {
        case .introductory:
            return subscription.introductoryOffer
        case .promotional:
            if let offerId {
                return subscription.promotionalOffers.first(where: { $0.id == offerId })
            }
        default:
            return nil
        }
        return nil
    }
}
