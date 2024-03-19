//
//  BackendProductState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct BackendProductState {
    let vendorId: String
    var introductoryOfferEligibility: AdaptyEligibility
    let version: Int64
}

extension BackendProductState: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), introductoryOfferEligibility: \(introductoryOfferEligibility), version: \(version))"
    }
}

extension BackendProductState: Sendable, Equatable {}

extension BackendProductState: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case introductoryOfferEligibility = "introductory_offer_eligibility"
        case version = "timestamp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vendorId = try container.decode(String.self, forKey: .vendorId)
        if let value = try? container.decode(AdaptyEligibility.self, forKey: .introductoryOfferEligibility) {
            introductoryOfferEligibility = value
        } else {
            introductoryOfferEligibility = try (container.decode(Bool.self, forKey: .introductoryOfferEligibility)) ? .eligible : .ineligible
        }
        version = try container.decode(Int64.self, forKey: .version)
    }
}

extension Sequence<BackendProductState> {
    var asDictionary: [String: BackendProductState] {
        Dictionary(map { ($0.vendorId, $0) }, uniquingKeysWith: { first, second in
            first.version > second.version ? first : second
        })
    }
}
