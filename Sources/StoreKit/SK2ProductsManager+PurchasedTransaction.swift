//
//  SK2ProductsManager+PurchasedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import Foundation

private let log = Log.Category(name: "SK2ProductsManager")

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager {
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String? = nil,
        purchasedSK2Transaction transaction: SK2Transaction
    ) async -> PurchasedTransaction {
        let productId = transaction.productID

        let sk2Product: SK2Product?
        do {
            sk2Product = try await fetchSK2Product(id: productId, fetchPolicy: .returnCacheDataElseLoad)
        } catch {
            log.error("fetch SK2Product \(productId) error: \(error)")
            sk2Product = nil
        }

        return PurchasedTransaction(
            sk2Product: sk2Product,
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            purchasedSK2Transaction: transaction
        )
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
            #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
                if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                    return .init(transaction.offer, sk2Product: sk2Product)
                }
            #endif
            return .init(transaction, sk2Product: sk2Product)
        }()

        self.init(
            transactionId: transaction.unfIdentifier,
            originalTransactionId: transaction.unfOriginalIdentifier,
            vendorProductId: transaction.productID,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.unfCurrencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.unfRegionCode,
            subscriptionOffer: offer,
            environment: transaction.unfEnvironment
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction.SubscriptionOffer {
    init?(_ transaction: SK2Transaction, sk2Product: SK2Product?) {
        guard let offerType = transaction.unfOfferType else { return nil }
        let productOffer = sk2Product?.subscriptionOffer(byType: offerType, withId: transaction.unfOfferId)
        self = .init(
            id: transaction.unfOfferId,
            period: (productOffer?.period).map { $0.asAdaptyProductSubscriptionPeriod },
            paymentMode: (productOffer?.paymentMode).map { $0.asPaymentMode } ?? .unknown,
            offerType: offerType.asPurchasedTransactionOfferType,
            price: productOffer?.price
        )
    }

    #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
        @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
        init?(_ transactionOffer: SK2Transaction.Offer?, sk2Product: SK2Product?) {
            guard let transactionOffer else { return nil }
            let productOffer = sk2Product?.subscriptionOffer(byType: transactionOffer.type, withId: transactionOffer.id)
            self = .init(
                id: transactionOffer.id,
                period: (productOffer?.period).map { $0.asAdaptyProductSubscriptionPeriod },
                paymentMode: transactionOffer.paymentMode.map { $0.asPaymentMode } ?? .unknown,
                offerType: transactionOffer.type.asPurchasedTransactionOfferType,
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
