//
//  AdaptyPaywallVariations.Draw.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

extension AdaptyPaywallVariations {
    struct Draw: Sendable {
        let profileId: String
        var paywall: AdaptyPaywall
        let placementAudienceVersionId: String
        let variationIdByPlacements: [String: String]
    }
}

extension AdaptyPaywallVariations.Draw {
    var participatesInCrossPlacementABTest: Bool { !variationIdByPlacements.isEmpty }

    private func replacedPaywall(_ paywall: AdaptyPaywall) -> Self {
        var draw = self
        draw.paywall = paywall
        return draw
    }

    func replacedPaywallVersion(_ version: Int64) -> Self {
        var paywall = paywall
        paywall.version = version
        return replacedPaywall(paywall)
    }
}

extension AdaptyPaywallVariations.Draw: Decodable {
    init(from decoder: Decoder) throws {
        let profileId = try decoder.userInfo.profileId

        if let singleItem = try? Variation(from: decoder) {
            if let variationId = decoder.userInfo.paywallVariationIdOrNil, singleItem.variationId != variationId {
                throw ResponseDecodingError.notFoundVariationId
            }

            try self.init(
                profileId: profileId,
                paywall: AdaptyPaywall(from: decoder),
                placementAudienceVersionId: singleItem.placementAudienceVersionId,
                variationIdByPlacements: singleItem.variationIdByPlacements
            )
            return
        }

        let items = try [Variation](from: decoder)
        guard let firstItem = items.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywalls collection is empty"))
        }

        let index: Int
        if let variationId = decoder.userInfo.paywallVariationIdOrNil {
            guard let foundedIndex = items.firstIndex(where: { $0.variationId == variationId }) else {
                throw ResponseDecodingError.notFoundVariationId
            }
            index = foundedIndex
        } else if items.count == 1 {
            index = 0
        } else {
            index = Self.draw(
                items: items,
                placementAudienceVersionId: firstItem.placementAudienceVersionId,
                profileId: profileId
            )
        }

        guard items.indices.contains(index) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywall with index \(index) not found"))
        }

        let item = items[index]
        try self.init(
            profileId: profileId,
            paywall: AdaptyPaywallVariations.paywall(from: decoder, index: index),
            placementAudienceVersionId: item.placementAudienceVersionId,
            variationIdByPlacements: item.variationIdByPlacements
        )
    }

    private static func draw(
        items: [Variation],
        placementAudienceVersionId: String,
        profileId: String
    ) -> Int {
        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let sortedItems = items
            .enumerated()
            .sorted(by: { first, second in
                if first.element.weight == second.element.weight {
                    first.element.variationId < second.element.variationId
                } else {
                    first.element.weight < second.element.weight
                }
            })

        let index = sortedItems.firstIndex { item in
            weight -= item.element.weight
            return weight <= 0
        } ?? (items.count - 1)

        return sortedItems[index].offset
    }

    private struct Variation: Sendable, Decodable {
        let placementAudienceVersionId: String
        let variationId: String
        let variationIdByPlacements: [String: String]
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case placementAudienceVersionId = "placement_audience_version_id"
            case variationId = "variation_id"
            case weight
            case crossPlacementInfo = "cross_placement_info"
            case attributes
        }

        private enum CrossPlacementCodingKeys: String, CodingKey {
            case variationIdByPlacements = "placement_with_variation_map"
        }

        var isCrossPlacementTest: Bool {
            !variationIdByPlacements.isEmpty
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.attributes) {
                container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            }

            placementAudienceVersionId = try container.decode(String.self, forKey: .placementAudienceVersionId)
            variationId = try container.decode(String.self, forKey: .variationId)
            weight = try container.decode(Int.self, forKey: .weight)

            if container.contains(.crossPlacementInfo),
               !((try? container.decodeNil(forKey: .crossPlacementInfo)) ?? true)
            {
                let crossPlacementInfo = try container.nestedContainer(keyedBy: CrossPlacementCodingKeys.self, forKey: .crossPlacementInfo)
                variationIdByPlacements = try crossPlacementInfo.decode([String: String].self, forKey: .variationIdByPlacements)
            } else {
                variationIdByPlacements = [:]
            }
        }
    }
}
