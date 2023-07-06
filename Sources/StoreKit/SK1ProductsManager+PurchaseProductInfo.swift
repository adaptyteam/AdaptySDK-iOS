//
//  SK1ProductsManager+PurchaseProductInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2023
//

import StoreKit

extension SKProductsManager {
    func fetchPurchaseProductInfo(variationId: String?,
                                  persistentVariationId: String? = nil,
                                  purchasedTransaction transaction: SKPaymentTransaction,
                                  _ completion: @escaping (PurchaseProductInfo) -> Void) {
        let productId = transaction.payment.productIdentifier

        fetchSK1Product(productIdentifier: productId, fetchPolicy: .returnCacheDataElseLoad) { result in
            switch result {
            case let .failure(error):
                Log.error("SKQueueManager: fetch SK1Product \(productId) error: \(error)")
                completion(PurchaseProductInfo(variationId, persistentVariationId, purchasedTransaction: transaction))
                return
            case let .success(skProduct):
                completion(PurchaseProductInfo(skProduct, variationId, persistentVariationId, purchasedTransaction: transaction))
                return
            }
        }
    }
}

extension PurchaseProductInfo {
    fileprivate init(_ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: SKPaymentTransaction) {
        self.init(transactionId: transaction.transactionIdentifier,
                  vendorProductId: transaction.payment.productIdentifier,
                  productVariationId: variationId,
                  persistentProductVariationId: persistentVariationId,
                  originalPrice: nil,
                  discountPrice: nil,
                  priceLocale: nil,
                  storeCountry: nil,
                  promotionalOfferId: nil,
                  offer: nil)
    }

    init(_ product: SKProduct, _ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: SKPaymentTransaction) {
        var discount: AdaptyProductDiscount?

        if #available(iOS 12.2, OSX 10.14.4, *),
           let identifier = transaction.payment.paymentDiscount?.identifier {
            // trying to extract promotional offer from transaction
            discount = AdaptyProductDiscount(
                discount: product.discounts.first(where: { $0.identifier == identifier }),
                locale: product.priceLocale
            )
        }
        if discount == nil {
            // fill with introductory offer details by default if possible
            // server handles introductory price application
            discount = product.adaptyIntroductoryDiscount
        }

        self.init(transactionId: transaction.transactionIdentifier,
                  vendorProductId: transaction.payment.productIdentifier,
                  productVariationId: variationId,
                  persistentProductVariationId: persistentVariationId,
                  originalPrice: product.price.decimalValue,
                  discountPrice: discount?.price,
                  priceLocale: product.priceLocale.currencyCode,
                  storeCountry: product.priceLocale.regionCode,
                  promotionalOfferId: discount?.identifier,
                  offer: PurchaseProductInfo.Offer(discount))
    }
}

fileprivate extension PurchaseProductInfo.Offer {
    init?(_ discount: AdaptyProductDiscount?) {
        guard let discount = discount else { return nil }
        self.init(periodUnit: discount.subscriptionPeriod.unit,
                  numberOfUnits: discount.subscriptionPeriod.numberOfUnits,
                  type: discount.paymentMode)
    }
}
