//
//  BackendProduct.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct BackendProduct {
    let vendorId: String
    let promotionalOfferEligibility: Bool
    var introductoryOfferEligibility: IntroductoryOfferEligibility
    let promotionalOfferId: String?
    let version: Int64
}

extension BackendProduct: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), promotionalOfferEligibility: \(promotionalOfferEligibility), introductoryOfferEligibility: \(introductoryOfferEligibility))"
    }
}

extension BackendProduct: Sendable, Equatable {}

extension BackendProduct: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case introductoryOfferEligibility = "introductory_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"

        case version = "timestamp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vendorId = try container.decode(String.self, forKey: .vendorId)
        promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
        promotionalOfferEligibility = try container.decode(Bool.self, forKey: .promotionalOfferEligibility)
        if let value = try? container.decode(IntroductoryOfferEligibility.self, forKey: .introductoryOfferEligibility) {
            introductoryOfferEligibility = value
        } else {
            introductoryOfferEligibility = (try container.decode(Bool.self, forKey: .introductoryOfferEligibility)) ? .eligible : .ineligible
        }
        version = try container.decode(Int64.self, forKey: .version)
    }
}

extension BackendProduct {
    func map(syncedBundleReceipt: Bool) -> Self {
        guard !syncedBundleReceipt, introductoryOfferEligibility == .eligible else { return self }
        var product = self
        product.introductoryOfferEligibility = .unknown
        return product
    }
}

extension Array where Element == BackendProduct {
    func map(syncedBundleReceipt: Bool) -> [BackendProduct] {
        guard !syncedBundleReceipt else { return self }
        return map { $0.map(syncedBundleReceipt: syncedBundleReceipt) }
    }
}

extension Sequence where Element == BackendProduct {
    var asDictionary: [String: BackendProduct] {
        Dictionary(uniqueKeysWithValues: map { ($0.vendorId, $0) })
    }
}
