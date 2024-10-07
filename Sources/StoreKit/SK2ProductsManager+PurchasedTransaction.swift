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
        persistentVariationId: String?,
        purchasedSK1Transaction sk1Transaction: (value: SK1Transaction, id: String)
    ) async -> PurchasedTransaction {
        await .init(
            sk2Product: try? fetchSK2Product(
                id: sk1Transaction.value.payment.productIdentifier,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            sk1Transaction: sk1Transaction
        )
    }

    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK2Transaction sk2Transaction: SK2Transaction
    ) async -> PurchasedTransaction {
        await .init(
            sk2Product: try? fetchSK2Product(
                id: sk2Transaction.productID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            sk2Transaction: sk2Transaction
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction {
    init(
        sk2Product: SK2Product?,
        variationId: String?,
        persistentVariationId: String?,
        sk1Transaction: (value: SK1Transaction, id: String)
    ) {
        let (sk1Transaction, transactionIdentifier) = sk1Transaction

        let offer = PurchasedTransaction.SubscriptionOffer(
            sk1Transaction: sk1Transaction,
            sk2Product: sk2Product
        )

        self.init(
            transactionId: sk1Transaction.unfIdentifier ?? transactionIdentifier,
            originalTransactionId: sk1Transaction.unfOriginalIdentifier ?? transactionIdentifier,
            vendorProductId: sk1Transaction.payment.productIdentifier,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.unfCurrencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.unfRegionCode,
            subscriptionOffer: offer,
            environment: nil
        )
    }

    init(
        sk2Product: SK2Product?,
        variationId: String?,
        persistentVariationId: String?,
        sk2Transaction: SK2Transaction
    ) {
        let offer: PurchasedTransaction.SubscriptionOffer? = {
            #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
                if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                    return .init(
                        sk2TransactionOffer: sk2Transaction.offer,
                        sk2Product: sk2Product
                    )
                }
            #endif
            return .init(
                sk2Transaction: sk2Transaction,
                sk2Product: sk2Product
            )
        }()

        self.init(
            transactionId: sk2Transaction.unfIdentifier,
            originalTransactionId: sk2Transaction.unfOriginalIdentifier,
            vendorProductId: sk2Transaction.productID,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.unfCurrencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.unfRegionCode,
            subscriptionOffer: offer,
            environment: sk2Transaction.unfEnvironment
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction.SubscriptionOffer {
    init?(
        sk1Transaction: SK1Transaction,
        sk2Product: SK2Product?
    ) {
        if let discountIdentifier = sk1Transaction.payment.paymentDiscount?.identifier {
            if let sk2ProductOffer = sk2Product?.subscriptionOffer(byType: .promotional, withId: discountIdentifier) {
                self.init(
                    id: discountIdentifier,
                    period: sk2ProductOffer.period.asAdaptyProductSubscriptionPeriod,
                    paymentMode: sk2ProductOffer.paymentMode.asPaymentMode,
                    offerType: .promotional,
                    price: sk2ProductOffer.price
                )
            } else {
                self.init(id: discountIdentifier, offerType: .promotional)
            }
        } else if let offer = sk2Product?.subscription?.introductoryOffer {
            self.init(
                id: nil,
                period: offer.period.asAdaptyProductSubscriptionPeriod,
                paymentMode: offer.paymentMode.asPaymentMode,
                offerType: .introductory,
                price: offer.price
            )
        } else {
            return nil
        }
    }

    init?(
        sk2Transaction: SK2Transaction,
        sk2Product: SK2Product?
    ) {
        guard let offerType = sk2Transaction.unfOfferType?.asPurchasedTransactionOfferType else { return nil }
        let sk2ProductOffer = sk2Product?.subscriptionOffer(
            byType: offerType,
            withId: sk2Transaction.unfOfferId
        )
        self = .init(
            id: sk2Transaction.unfOfferId,
            period: (sk2ProductOffer?.period)?.asAdaptyProductSubscriptionPeriod,
            paymentMode: (sk2ProductOffer?.paymentMode)?.asPaymentMode ?? .unknown,
            offerType: offerType,
            price: sk2ProductOffer?.price
        )
    }

    #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
        @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
        init?(
            sk2TransactionOffer: SK2Transaction.Offer?,
            sk2Product: SK2Product?
        ) {
            guard let sk2TransactionOffer else { return nil }
            let sk2ProductOffer = sk2Product?.subscriptionOffer(
                byType: sk2TransactionOffer.type.asPurchasedTransactionOfferType,
                withId: sk2TransactionOffer.id
            )
            self = .init(
                id: sk2TransactionOffer.id,
                period: (sk2ProductOffer?.period).map { $0.asAdaptyProductSubscriptionPeriod },
                paymentMode: sk2TransactionOffer.paymentMode.map { $0.asPaymentMode } ?? .unknown,
                offerType: sk2TransactionOffer.type.asPurchasedTransactionOfferType,
                price: sk2ProductOffer?.price
            )
        }
    #endif
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension SK2Product {
    func subscriptionOffer(
        byType offerType: PurchasedTransaction.OfferType,
        withId offerId: String?
    ) -> SK2Product.SubscriptionOffer? {
        guard let subscription else { return nil }

        switch offerType {
        case .introductory:
            return subscription.introductoryOffer
        case .promotional:
            if let offerId {
                return subscription.promotionalOffers.first { $0.id == offerId }
            }
        case .code:
            return nil
        case .winBack:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *), let offerId {
                return subscription.winBackOffers.first { $0.id == offerId }
            }
        default:
            return nil
        }

        return nil
    }
}
