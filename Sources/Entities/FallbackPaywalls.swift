//
//  FallbackPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

struct FallbackPaywalls {
    let paywallByPlacementId: [String: AdaptyPaywall]
    let allProductVendorIds: [String]
    let version: Int
}

extension FallbackPaywalls: Decodable {
    enum CodingKeys: String, CodingKey {
        case data
        case meta
        case products
        case version
    }

    private struct PaywallContainer: Decodable {
        let paywall: AdaptyPaywall

        enum CodingKeys: String, CodingKey {
            case paywall = "attributes"
        }
    }

    private struct ProductContainer: Decodable {
        let vendorId: String
        enum CodingKeys: String, CodingKey {
            case vendorId = "vendor_product_id"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subcontainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

        if let subcontainer,
           let v = try subcontainer.decodeIfPresent(Int.self, forKey: .version) {
            version = v
        } else {
            version = 0
        }

        var productVendorIds = Set<String>()

        if let containers = try container.decodeIfPresent([PaywallContainer].self, forKey: .data) {
            let paywallsArray = containers.map { $0.paywall }
            paywallByPlacementId = try [String: AdaptyPaywall](paywallsArray.map { ($0.placementId, $0) }, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.data], debugDescription: "Duplicate paywalls placementId"))
            })
            productVendorIds = Set(paywallsArray.flatMap { $0.products.map { $0.vendorId } })
        } else {
            paywallByPlacementId = [:]
        }

        if let subcontainer,
           let productsArray = try subcontainer.decodeIfPresent([ProductContainer].self, forKey: .products),
           !productsArray.isEmpty {
            productVendorIds = productVendorIds.union(productsArray.map { $0.vendorId })
        }

        allProductVendorIds = Array(productVendorIds)
    }

    init(from data: Data) throws {
        self = try Backend.decoder.decode(FallbackPaywalls.self, from: data)
    }
}
