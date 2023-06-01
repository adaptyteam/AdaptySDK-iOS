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
