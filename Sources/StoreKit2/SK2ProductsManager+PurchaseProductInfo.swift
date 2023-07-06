//
//  SK2ProductsManager+PurchaseProductInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2023
//

import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
extension SKProductsManager {
    func fetchPurchaseProductInfo(variationId: String?,
                                  persistentVariationId: String? = nil,
                                  purchasedTransaction transaction: Transaction,
                                  _ completion: @escaping (PurchaseProductInfo) -> Void) {
        let productId = transaction.productID

        fetchSK2Product(productIdentifier: productId, fetchPolicy: .returnCacheDataElseLoad) { result in
            switch result {
            case let .failure(error):
                Log.error("SKQueueManager: fetch SK2Product \(productId) error: \(error)")
                completion(PurchaseProductInfo(variationId, persistentVariationId, purchasedTransaction: transaction))
                return
            case let .success(skProduct):
                completion(PurchaseProductInfo(skProduct, variationId, persistentVariationId, purchasedTransaction: transaction))
                return
            }
        }
    }
}

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
fileprivate extension PurchaseProductInfo {
    init(_ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: Transaction) {
        self.init(transactionId: String(transaction.id),
                  vendorProductId: transaction.productID,
                  productVariationId: variationId,
                  persistentProductVariationId: persistentVariationId,
                  originalPrice: nil,
                  discountPrice: nil,
                  priceLocale: nil,
                  storeCountry: nil,
                  promotionalOfferId: nil,
                  offer: nil)
    }

    init(_ product: Product, _ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: Transaction) {
        var offer: Product.SubscriptionOffer?

        if let identifier = transaction.offerID {
            // trying to extract promotional offer from transaction
            offer = product.subscription?.promotionalOffers.first(where: { $0.id == identifier })
        }

        if offer == nil {
            // fill with introductory offer details by default if possible
            // server handles introductory price application
            offer = product.subscription?.introductoryOffer
        }

        self.init(transactionId: String(transaction.id),
                  vendorProductId: transaction.productID,
                  productVariationId: variationId,
                  persistentProductVariationId: persistentVariationId,
                  originalPrice: product.price,
                  discountPrice: offer?.price,
                  priceLocale: product.priceFormatStyle.locale.currencyCode,
                  storeCountry: product.priceFormatStyle.locale.regionCode,
                  promotionalOfferId: offer?.id,
                  offer: PurchaseProductInfo.Offer(offer))
    }
}

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
fileprivate extension PurchaseProductInfo.Offer {
    init?(_ offer: Product.SubscriptionOffer?) {
        guard let offer = offer else { return nil }
        self.init(periodUnit: AdaptyPeriodUnit(unit: offer.period.unit),
                  numberOfUnits: offer.period.value,
                  type: AdaptyProductDiscount.PaymentMode(mode: offer.paymentMode))
    }
}
