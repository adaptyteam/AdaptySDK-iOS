//
//  PurchaseProductInfo.swift
//  Adapty
//
//  Created by Aleksei Valiano on 08.09.2022.
//
import StoreKit

struct PurchaseProductInfo {
    let transactionId: String? //
    let vendorProductId: String
    let productVariationId: String?
    let persistentProductVariationId: String?
    let originalPrice: Decimal?
    let discountPrice: Decimal?
    let priceLocale: String?
    let storeCountry: String?
    let promotionalOfferId: String?
    let offer: Offer?

    struct Offer {
        let periodUnit: AdaptyPeriodUnit
        let numberOfUnits: Int
        let type: AdaptyProductDiscount.PaymentMode
    }
}

extension PurchaseProductInfo: Sendable {}
extension PurchaseProductInfo.Offer: Sendable {}

extension PurchaseProductInfo.Offer: Encodable {
    enum CodingKeys: String, CodingKey {
        case periodUnit = "period_unit"
        case numberOfUnits = "number_of_units"
        case type
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(periodUnit, forKey: .periodUnit)
        try container.encode(numberOfUnits, forKey: .numberOfUnits)
        try container.encode(type, forKey: .type)
    }
}

extension PurchaseProductInfo: Encodable {
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case vendorProductId = "vendor_product_id"
        case productVariationId = "variation_id"
        case persistentProductVariationId = "variation_id_persistent"
        case originalPrice = "original_price"
        case discountPrice = "discount_price"
        case priceLocale = "price_locale"
        case storeCountry = "store_country"
        case promotionalOfferId = "promotional_offer_id"
        case offer
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(transactionId, forKey: .transactionId)
        try container.encode(vendorProductId, forKey: .vendorProductId)
        try container.encodeIfPresent(productVariationId, forKey: .productVariationId)
        try container.encodeIfPresent(persistentProductVariationId, forKey: .persistentProductVariationId)
        try container.encodeIfPresent(originalPrice, forKey: .originalPrice)
        try container.encodeIfPresent(discountPrice, forKey: .discountPrice)
        try container.encodeIfPresent(priceLocale, forKey: .priceLocale)
        try container.encodeIfPresent(storeCountry, forKey: .storeCountry)
        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
        try container.encodeIfPresent(offer, forKey: .offer)
    }
}

extension PurchaseProductInfo {
    init(_ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: SKPaymentTransaction) {
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

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    init(_ product: Product, _ variationId: String?, _ persistentVariationId: String?, purchasedTransaction transaction: Transaction) {
        var offer: Product.SubscriptionOffer?

        if let identifier = transaction.offerID {
            // trying to extract promotional offer from transaction
            offer = product.subscription?.promotionalOffers.first(where: { $0.id == identifier })
        }

        if offer == nil  {
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

extension PurchaseProductInfo.Offer {
    init?(_ discount: AdaptyProductDiscount?) {
        guard let discount = discount else { return nil }
        self.init(periodUnit: discount.subscriptionPeriod.unit,
                  numberOfUnits: discount.subscriptionPeriod.numberOfUnits,
                  type: discount.paymentMode)
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    init?(_ offer: Product.SubscriptionOffer?) {
        guard let offer = offer else { return nil }
        self.init(periodUnit: AdaptyPeriodUnit(unit: offer.period.unit),
                  numberOfUnits: offer.period.value,
                  type: AdaptyProductDiscount.PaymentMode(mode: offer.paymentMode))
    }
}
